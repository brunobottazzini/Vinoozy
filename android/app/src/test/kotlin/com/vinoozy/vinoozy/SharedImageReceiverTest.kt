package com.vinoozy.vinoozy

import android.app.Application
import android.content.ContentProvider
import android.content.ContentValues
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStream
import java.util.function.Supplier

/**
 * SharedImageReceiver (u6-label-recognition BR1.4, NFR4.4, NFR4.5,
 * cicd-pipeline.md §1): what is accepted at reception, the consumed intent in
 * onCreate and onNewIntent, the first URI only, the copy stopped at 20 MB.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class SharedImageReceiverTest {
    @get:Rule
    val temp = TemporaryFolder()

    private val context: Application = ApplicationProvider.getApplicationContext()
    private val resolver = context.contentResolver
    private lateinit var preparer: LabelImagePreparer
    private lateinit var receiver: SharedImageReceiver
    private val replaced = mutableListOf<Intent>()
    private val replace: (Intent) -> Unit = { replaced.add(it) }

    @Before
    fun setUp() {
        preparer = LabelImagePreparer(temp.newFolder("cache"), sdkInt = 34)
        receiver = SharedImageReceiver(resolver, preparer)
    }

    private fun uri(name: String) = Uri.parse("content://media.test/images/$name")

    private fun jpegBytes(): ByteArray {
        val bitmap = Bitmap.createBitmap(60, 40, Bitmap.Config.ARGB_8888)
        return ByteArrayOutputStream().also { bitmap.compress(Bitmap.CompressFormat.JPEG, 90, it) }.toByteArray()
    }

    private fun serve(uri: Uri, bytes: ByteArray, opened: MutableList<Uri>? = null) {
        shadowOf(resolver).registerInputStreamSupplier(uri, Supplier<InputStream> {
            opened?.add(uri)
            ByteArrayInputStream(bytes)
        })
    }

    private fun send(uri: Uri?, type: String? = "image/jpeg") = Intent(Intent.ACTION_SEND).apply {
        if (type != null) setType(type)
        if (uri != null) putExtra(Intent.EXTRA_STREAM, uri)
    }

    private fun sendMultiple(vararg uris: Uri) = Intent(Intent.ACTION_SEND_MULTIPLE).apply {
        type = "image/*"
        putParcelableArrayListExtra(Intent.EXTRA_STREAM, arrayListOf(*uris))
    }

    private fun labelFiles(): List<String> = preparer.labelDir.list()?.toList().orEmpty()

    /** A first start: no saved state. */
    private fun SharedImageReceiver.onCreateFresh(intent: Intent?, replace: (Intent) -> Unit) =
        onCreate(intent, restored = false, replaceIntent = replace)

    @Test
    fun aRestoredActivityDoesNotDeliverTheOldShareAgain() {
        assertFalse(receiver.onCreate(send(uri("old")), restored = true, replaceIntent = replace))
        assertFalse(receiver.hasPending)
        assertNull(receiver.pendingInfo())
        assertEquals("the old intent is consumed", 1, replaced.size)
        assertNull(replaced.single().action)
    }

    @Test
    fun anActivityReopenedFromRecentsDoesNotDeliverTheOldShareAgain() {
        val fromHistory = send(uri("old")).addFlags(Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY)
        assertFalse(receiver.onCreate(fromHistory, restored = false, replaceIntent = replace))
        assertFalse(receiver.hasPending)
        assertEquals(1, replaced.size)
        // A restored launcher intent is left alone.
        assertFalse(receiver.onCreate(Intent(Intent.ACTION_MAIN), restored = true, replaceIntent = replace))
        assertEquals(1, replaced.size)
    }

    @Test
    fun onCreateKeepsTheUriOnlyAndConsumesTheIntent() {
        val image = uri("1")
        assertTrue(receiver.onCreateFresh(send(image), replace))
        assertTrue(receiver.hasPending)
        assertEquals(mapOf("multiple" to false), receiver.pendingInfo())
        assertEquals(1, replaced.size)
        assertNull("replaced with an empty intent", replaced.single().action)
        assertTrue("no copy at reception", labelFiles().isEmpty())
    }

    @Test
    fun onNewIntentAlsoConsumesTheIntentAndReplacesTheOldShare() {
        receiver.onCreateFresh(send(uri("old")), replace)
        assertTrue(receiver.onNewIntent(send(uri("new")), replace))
        assertEquals(2, replaced.size)
        val taken = receiver.takePending() as PendingShare.Image
        assertEquals(uri("new"), taken.uri)
    }

    @Test
    fun otherActionsAreIgnoredAndNotConsumed() {
        assertFalse(receiver.onCreateFresh(Intent(Intent.ACTION_MAIN), replace))
        assertFalse(receiver.onNewIntent(Intent(Intent.ACTION_VIEW, uri("x")), replace))
        assertFalse(receiver.onCreateFresh(null, replace))
        assertTrue(replaced.isEmpty())
        assertFalse(receiver.hasPending)
        assertNull(receiver.pendingInfo())
    }

    @Test
    fun aFileSchemeIsRefused() {
        receiver.onCreateFresh(send(Uri.parse("file:///sdcard/DCIM/a.jpg")), replace)
        val share = receiver.takePending()!!
        assertEquals(PrepareResult.Rejected(RejectCode.SCHEME), receiver.read(share))
    }

    @Test
    fun aMissingStreamIsRefusedWithTheSchemeCode() {
        receiver.onCreateFresh(send(null), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.SCHEME), receiver.read(receiver.takePending()!!))
    }

    @Test
    fun aDeclaredTypeOtherThanAnImageIsRefused() {
        receiver.onCreateFresh(send(uri("doc"), type = "text/plain"), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.TYPE), receiver.read(receiver.takePending()!!))
        receiver.onCreateFresh(send(uri("doc"), type = null), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.TYPE), receiver.read(receiver.takePending()!!))
    }

    @Test
    fun aProviderTypeOtherThanAnImageIsRefusedBeforeCopying() {
        Robolectric.setupContentProvider(TextTypeProvider::class.java, "text.test")
        receiver.onCreateFresh(send(Uri.parse("content://text.test/notes")), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.TYPE), receiver.read(receiver.takePending()!!))
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun sendMultipleUsesOnlyTheFirstUri() {
        val opened = mutableListOf<Uri>()
        val first = uri("first")
        val second = uri("second")
        serve(first, jpegBytes(), opened)
        serve(second, jpegBytes(), opened)
        assertTrue(receiver.onCreateFresh(sendMultiple(first, second, uri("third")), replace))
        assertEquals(mapOf("multiple" to true), receiver.pendingInfo())
        val share = receiver.takePending()!!
        assertTrue(share.multiple)
        assertTrue(receiver.read(share) is PrepareResult.Ready)
        assertEquals(listOf(first), opened)
    }

    @Test
    fun aSharedJpegIsCopiedPreparedAndTheCopyDeleted() {
        val image = uri("photo")
        serve(image, jpegBytes())
        receiver.onCreateFresh(send(image), replace)
        val result = receiver.read(receiver.takePending()!!) as PrepareResult.Ready
        assertTrue(File(result.path).exists())
        assertEquals(listOf(File(result.path).name), labelFiles())
        assertFalse(receiver.hasPending)
    }

    @Test
    fun anEndlessStreamStopsAt20MbAndIsDeleted() {
        val endless = CountingZeros()
        val image = uri("endless")
        shadowOf(resolver).registerInputStreamSupplier(image, Supplier<InputStream> { endless })
        receiver.onNewIntent(send(image), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.SIZE), receiver.read(receiver.takePending()!!))
        assertTrue(endless.count <= LabelImagePreparer.MAX_BYTES + SharedImageReceiver.COPY_CHUNK_BYTES)
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun bytesThatAreNotAnImageWithAnImageTypeAreRefused() {
        val image = uri("lie")
        serve(image, ByteArray(2048) { 7 })
        receiver.onCreateFresh(send(image, type = "image/jpeg"), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.FORMAT), receiver.read(receiver.takePending()!!))
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun anUnreadableStreamIsADecodeRejection() {
        val image = uri("broken")
        shadowOf(resolver).registerInputStreamSupplier(image, Supplier<InputStream> { throw SecurityException("no grant") })
        receiver.onCreateFresh(send(image), replace)
        assertEquals(PrepareResult.Rejected(RejectCode.DECODE), receiver.read(receiver.takePending()!!))
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun discardDropsTheReference() {
        receiver.onCreateFresh(send(uri("1")), replace)
        receiver.discard()
        assertFalse(receiver.hasPending)
        assertNull(receiver.takePending())
    }

    /** An endless stream of zeros that counts what was read. */
    private class CountingZeros : InputStream() {
        var count = 0L

        override fun read(): Int {
            count++
            return 0
        }

        override fun read(buffer: ByteArray, offset: Int, length: Int): Int {
            buffer.fill(0, offset, offset + length)
            count += length
            return length
        }
    }
}

/** A provider that declares its content as text. */
class TextTypeProvider : ContentProvider() {
    override fun onCreate() = true
    override fun getType(uri: Uri) = "text/plain"
    override fun query(uri: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, s: String?, a: Array<String>?) = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?) = 0
}

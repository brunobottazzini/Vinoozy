package com.vinoozy.vinoozy

import android.app.Application
import android.content.Intent
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
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The text shared by Google Lens (label-autofill-windows FR2.1, BR2.3,
 * BR2.4, NFR3.2): ACTION_SEND of text/plain is kept in memory, cut to 4000
 * characters, taken once, and never shown by pendingInfo or toString.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class SharedTextReceiverTest {
    @get:Rule
    val temp = TemporaryFolder()

    private val context: Application = ApplicationProvider.getApplicationContext()
    private lateinit var receiver: SharedImageReceiver
    private val replaced = mutableListOf<Intent>()
    private val replace: (Intent) -> Unit = { replaced.add(it) }

    @Before
    fun setUp() {
        receiver = SharedImageReceiver(
            context.contentResolver,
            LabelImagePreparer(temp.newFolder("cache"), sdkInt = 34),
        )
    }

    private fun sendText(text: CharSequence?) = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        if (text != null) putExtra(Intent.EXTRA_TEXT, text)
    }

    @Test
    fun aSharedTextIsKeptAndTakenOnce() {
        assertTrue(receiver.onCreate(sendText("Barolo\n2016"), restored = false, replaceIntent = replace))
        assertEquals(1, replaced.size)
        assertEquals(mapOf("multiple" to false, "kind" to "text"), receiver.pendingInfo())
        assertEquals("Barolo\n2016", receiver.takeText())
        assertNull(receiver.takeText())
        assertFalse(receiver.hasPending)
    }

    @Test
    fun theTextIsCutTo4000CharactersNeverInAPair() {
        receiver.onNewIntent(sendText("a".repeat(5000)), replace)
        assertEquals(4000, receiver.takeText()!!.length)
        val emoji = "a".repeat(3999) + "🍷" + "tail"
        assertEquals(3999, SharedImageReceiver.clampText(emoji).length)
        assertEquals("short", SharedImageReceiver.clampText("short"))
    }

    @Test
    fun anEmptyTextIsKeptSoDartCanSayNoTextReceived() {
        receiver.onNewIntent(sendText(null), replace)
        assertEquals("", receiver.takeText())
    }

    @Test
    fun theTextNeverAppearsInTheStringFormNorInTheInfo() {
        receiver.onNewIntent(sendText("SECRET-TEXT"), replace)
        val share = receiver.takePending()!!
        assertFalse(share.toString().contains("SECRET"))
        assertEquals(PrepareResult.Rejected(RejectCode.TYPE), receiver.read(share))
    }

    @Test
    fun anImageShareIsNotAText() {
        receiver.onNewIntent(
            Intent(Intent.ACTION_SEND).apply { type = "image/jpeg" },
            replace,
        )
        assertNull(receiver.takeText())
        assertTrue(receiver.hasPending)
    }

    @Test
    fun aRestoredSendTextIntentIsNotANewShare() {
        assertFalse(receiver.onCreate(sendText("old"), restored = true, replaceIntent = replace))
        assertFalse(receiver.hasPending)
    }
}

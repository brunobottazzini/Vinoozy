package com.vinoozy.vinoozy

import android.app.Application
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.exifinterface.media.ExifInterface
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File
import java.io.RandomAccessFile

/**
 * LabelImagePreparer (u6-label-recognition cicd-pipeline.md §1, NFR4.4,
 * NFR8.1): the checks, the reduction to 2,048 px, the EXIF orientation and
 * the deletion of the input in every case. Real bitmaps with Robolectric's
 * native graphics; the decoder is replaced only to simulate an
 * OutOfMemoryError and a 60-million-pixel header.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class LabelImagePreparerTest {
    @get:Rule
    val temp = TemporaryFolder()

    private lateinit var cacheDir: File
    private lateinit var preparer: LabelImagePreparer

    @Before
    fun setUp() {
        cacheDir = temp.newFolder("cache")
        preparer = LabelImagePreparer(cacheDir, sdkInt = 34)
    }

    private fun bitmapFile(
        name: String,
        width: Int,
        height: Int,
        format: Bitmap.CompressFormat = Bitmap.CompressFormat.JPEG,
        dir: File = cacheDir,
    ): File {
        dir.mkdirs()
        val file = File(dir, name)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(0xFFEEDDCC.toInt())
        file.outputStream().use { bitmap.compress(format, 90, it) }
        return file
    }

    private fun bytesFile(name: String, bytes: ByteArray, dir: File = cacheDir): File =
        File(dir, name).apply { writeBytes(bytes) }

    private fun ready(result: PrepareResult): File {
        assertTrue("expected Ready, got $result", result is PrepareResult.Ready)
        return File((result as PrepareResult.Ready).path)
    }

    private fun sizeOf(file: File): Pair<Int, Int> {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(file.path, options)
        return options.outWidth to options.outHeight
    }

    private fun labelFiles(): List<String> = preparer.labelDir.list()?.toList().orEmpty()

    @Test
    fun aJpegInsideTheCacheBecomesAJpegInLabelAndTheInputIsDeleted() {
        val input = bitmapFile("pick.jpg", 300, 200)
        val output = ready(preparer.preparePickedPath(input.path))
        assertEquals(File(cacheDir, "label"), output.parentFile)
        assertTrue(output.name.endsWith(".jpg"))
        assertEquals(300 to 200, sizeOf(output))
        assertFalse("input deleted", input.exists())
    }

    @Test
    fun theReturnedPathStaysUnderTheNonCanonicalCacheDir() {
        // Like /data/user/0 -> /data/data on Android (review R-01): the app
        // gives a cacheDir through a symlink; Dart deletes under that path.
        val linked = File(temp.root, "user0-cache")
        java.nio.file.Files.createSymbolicLink(linked.toPath(), cacheDir.toPath())
        val viaLink = LabelImagePreparer(linked, sdkInt = 34)
        assertTrue(linked.canonicalPath != linked.path)

        // A picked file named through the link and one named by its real path.
        val throughLink = File(linked, "a.jpg").also {
            bitmapFile("a.jpg", 30, 20)
        }
        val first = ready(viaLink.preparePickedPath(throughLink.path))
        assertEquals(File(linked, "label").path, first.parentFile!!.path)

        val second = ready(viaLink.preparePickedPath(bitmapFile("b.jpg", 30, 20).path))
        assertTrue(second.path.startsWith(linked.path + File.separator))
        assertFalse(File(cacheDir, "a.jpg").exists())
        assertFalse(File(cacheDir, "b.jpg").exists())
        assertTrue(first.exists() && second.exists())
    }

    @Test
    fun aPngAndAWebpAreAccepted() {
        ready(preparer.preparePickedPath(bitmapFile("a.png", 40, 30, Bitmap.CompressFormat.PNG).path))
        @Suppress("DEPRECATION")
        ready(preparer.preparePickedPath(bitmapFile("b.webp", 40, 30, Bitmap.CompressFormat.WEBP).path))
        assertEquals(2, labelFiles().size)
    }

    @Test
    fun aLargeImageIsReducedTo2048OnTheLongSide() {
        val input = bitmapFile("big.jpg", 4100, 1000)
        val output = ready(preparer.preparePickedPath(input.path))
        val (width, height) = sizeOf(output)
        assertEquals(2048, width)
        assertEquals(500, height)
    }

    @Test
    fun theSampleSizeIsTheLargestPowerOfTwoKeeping2048() {
        assertEquals(1, preparer.sampleSizeFor(2048))
        assertEquals(1, preparer.sampleSizeFor(4095))
        assertEquals(2, preparer.sampleSizeFor(4096))
        assertEquals(4, preparer.sampleSizeFor(9000))
        assertEquals(1, preparer.sampleSizeFor(100))
    }

    @Test
    fun theExifOrientationIsApplied() {
        val input = bitmapFile("rotated.jpg", 200, 100)
        ExifInterface(input.path).apply {
            setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_ROTATE_90.toString())
            saveAttributes()
        }
        val output = ready(preparer.preparePickedPath(input.path))
        assertEquals(100 to 200, sizeOf(output))
    }

    @Test
    fun aPathOutsideTheCacheIsRefusedWithoutTouchingIt() {
        val outside = bitmapFile("gallery.jpg", 10, 10, dir = temp.newFolder("gallery"))
        assertEquals(PrepareResult.Rejected(RejectCode.SCHEME), preparer.preparePickedPath(outside.path))
        assertTrue("never deleted", outside.exists())
        val traversal = File(cacheDir, "../gallery/gallery.jpg").path
        assertEquals(PrepareResult.Rejected(RejectCode.SCHEME), preparer.preparePickedPath(traversal))
        assertTrue(outside.exists())
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun bytesThatAreNotAnImageAreRefusedAndDeleted() {
        val input = bytesFile("fake.jpg", ByteArray(4096) { (it * 31 % 251).toByte() })
        assertEquals(PrepareResult.Rejected(RejectCode.FORMAT), preparer.preparePickedPath(input.path))
        assertFalse(input.exists())
        val tiny = bytesFile("tiny.jpg", byteArrayOf(0xFF.toByte(), 0xD8.toByte()))
        assertEquals(PrepareResult.Rejected(RejectCode.FORMAT), preparer.preparePickedPath(tiny.path))
    }

    @Test
    fun aMissingFileIsAFormatRejection() {
        assertEquals(
            PrepareResult.Rejected(RejectCode.FORMAT),
            preparer.prepareFile(File(cacheDir, "missing.jpg")),
        )
    }

    @Test
    fun aFileOver20MbIsRefusedAndDeleted() {
        val input = File(cacheDir, "huge.jpg")
        RandomAccessFile(input, "rw").use {
            it.write(byteArrayOf(0xFF.toByte(), 0xD8.toByte(), 0xFF.toByte()))
            it.setLength(LabelImagePreparer.MAX_BYTES + 1)
        }
        assertEquals(PrepareResult.Rejected(RejectCode.SIZE), preparer.preparePickedPath(input.path))
        assertFalse(input.exists())
    }

    @Test
    fun sixtyMillionPixelsAreRefusedBeforeDecoding() {
        var decoded = false
        val header = object : LabelBitmapDecoder {
            override fun bounds(path: String) = 8000 to 7500
            override fun decode(path: String, sampleSize: Int): Bitmap? {
                decoded = true
                return null
            }
        }
        val input = bitmapFile("wide.jpg", 20, 20)
        val result = LabelImagePreparer(cacheDir, 34, header).preparePickedPath(input.path)
        assertEquals(PrepareResult.Rejected(RejectCode.SIZE), result)
        assertFalse("never decoded", decoded)
        assertFalse(input.exists())
    }

    @Test
    fun heicIsRefusedBeforeApi28AndTriedFromApi28() {
        val heic = ByteArray(64).also {
            "\u0000\u0000\u0000\u0018ftypheic".toByteArray(Charsets.US_ASCII).copyInto(it)
        }
        val api27 = LabelImagePreparer(cacheDir, sdkInt = 27)
        assertEquals(
            PrepareResult.Rejected(RejectCode.FORMAT),
            api27.preparePickedPath(bytesFile("old.heic", heic).path),
        )
        // From API 28 the format passes; these fake bytes then fail to decode.
        val api28 = LabelImagePreparer(cacheDir, sdkInt = 28)
        val input = bytesFile("new.heic", heic)
        assertEquals(PrepareResult.Rejected(RejectCode.DECODE), api28.preparePickedPath(input.path))
        assertFalse(input.exists())
    }

    @Test
    fun anOutOfMemoryErrorBecomesADecodeRejection() {
        val failing = object : LabelBitmapDecoder {
            override fun bounds(path: String) = 4000 to 3000
            override fun decode(path: String, sampleSize: Int): Bitmap? = throw OutOfMemoryError("simulated")
        }
        val input = bitmapFile("oom.jpg", 20, 20)
        val result = LabelImagePreparer(cacheDir, 34, failing).preparePickedPath(input.path)
        assertEquals(PrepareResult.Rejected(RejectCode.DECODE), result)
        assertFalse(input.exists())
        assertTrue(labelFiles().isEmpty())
    }

    @Test
    fun aNullDecodeIsADecodeRejection() {
        val empty = object : LabelBitmapDecoder {
            override fun bounds(path: String) = 10 to 10
            override fun decode(path: String, sampleSize: Int): Bitmap? = null
        }
        val input = bitmapFile("null.jpg", 10, 10)
        assertEquals(
            PrepareResult.Rejected(RejectCode.DECODE),
            LabelImagePreparer(cacheDir, 34, empty).preparePickedPath(input.path),
        )
    }

    @Test
    fun theEmptyFolderLeftByImagePickerIsDeleted() {
        val pickerDir = File(cacheDir, "3f2c")
        val input = bitmapFile("photo.jpg", 50, 50, dir = pickerDir)
        ready(preparer.preparePickedPath(input.path))
        assertFalse(pickerDir.exists())
        assertTrue(cacheDir.exists())
    }

    @Test
    fun theChannelMapCarriesOnlyThePathOrTheCode() {
        assertEquals(mapOf("path" to "/x/label/a.jpg"), PrepareResult.Ready("/x/label/a.jpg").toChannelMap())
        assertEquals(mapOf("rejected" to "size"), PrepareResult.Rejected(RejectCode.SIZE).toChannelMap())
    }
}

package com.vinoozy.vinoozy

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.os.Build
import androidx.exifinterface.media.ExifInterface
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID

/** Outcome of [LabelImagePreparer]: a ready JPEG, or a fixed rejection code. */
sealed class PrepareResult {
    data class Ready(val path: String) : PrepareResult()

    /** [code] is one of [RejectCode]; never a message nor a path (NFR8.2). */
    data class Rejected(val code: String) : PrepareResult()

    /** The map sent to Dart over the label channel. */
    fun toChannelMap(): Map<String, String> = when (this) {
        is Ready -> mapOf("path" to path)
        is Rejected -> mapOf("rejected" to code)
    }
}

/** The only rejection codes that reach Dart (u6 security-design.md §3). */
object RejectCode {
    const val SCHEME = "scheme"
    const val TYPE = "type"
    const val SIZE = "size"
    const val FORMAT = "format"
    const val DECODE = "decode"
}

/** Decoding seam: [AndroidBitmapDecoder] in the app, a fake in tests (OOM). */
interface LabelBitmapDecoder {
    /** Width and height read from the header, without decoding the pixels. */
    fun bounds(path: String): Pair<Int, Int>

    fun decode(path: String, sampleSize: Int): Bitmap?
}

object AndroidBitmapDecoder : LabelBitmapDecoder {
    override fun bounds(path: String): Pair<Int, Int> {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, options)
        return options.outWidth to options.outHeight
    }

    override fun decode(path: String, sampleSize: Int): Bitmap? =
        BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sampleSize })
}

/**
 * The single check and preparation point of every label image, shared or
 * from image_picker (u6-label-recognition security-design.md §3, NFR4.4,
 * NFR1.2). Dart never decodes nor checks an image itself.
 *
 * In order: size (20 MB), magic bytes (JPEG, PNG, WebP, HEIC; HEIC only from
 * API 28), pixels read from the header (50 million at most), decode with the
 * largest power-of-two `inSampleSize` that keeps the long side >= 2,048,
 * exact scale to 2,048, EXIF orientation, JPEG q90 in `cacheDir/label/`.
 * Every step is guarded with `catch (Throwable)`, OutOfMemoryError included:
 * the caller only ever gets a [PrepareResult]. The input file is deleted in
 * every case; it is always inside `cacheDir`.
 *
 * Runs on a background thread (MainActivity), never on the main thread.
 */
class LabelImagePreparer(
    cacheDir: File,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
    private val decoder: LabelBitmapDecoder = AndroidBitmapDecoder,
) {
    companion object {
        /** Same name in Dart (TempLabelStore.folderName). */
        const val LABEL_DIR_NAME = "label"
        const val MAX_BYTES = 20L * 1024 * 1024
        const val MAX_PIXELS = 50_000_000L
        const val TARGET_LONG_SIDE = 2048
        const val JPEG_QUALITY = 90
        private const val HEADER_BYTES = 12
        private val HEIC_BRANDS = setOf("heic", "heix", "hevc", "hevx", "heim", "heis", "mif1", "msf1")
    }

    private enum class Format { JPEG, PNG, WEBP, HEIC }

    /** Canonical, only for the confinement checks (symlinks resolved). */
    private val cacheRoot: File = cacheDir.canonicalFile
    private val canonicalLabelDir: File = File(cacheRoot, LABEL_DIR_NAME)

    /**
     * `cacheDir/label`, the one folder of the label files (NFR8.1), built from
     * the [cacheDir] as given, NOT canonicalized: Dart deletes the returned
     * paths under `getTemporaryDirectory()/label`, and on Android `/data/user/0`
     * is usually a symlink to `/data/data` (review R-01).
     */
    val labelDir: File = File(cacheDir, LABEL_DIR_NAME)

    /**
     * A file written by image_picker. Only canonical paths inside `cacheDir`
     * are accepted; any other path is refused with [RejectCode.SCHEME]
     * without reading or deleting it.
     */
    fun preparePickedPath(path: String): PrepareResult {
        val file = try {
            File(path).canonicalFile
        } catch (error: IOException) {
            return PrepareResult.Rejected(RejectCode.SCHEME)
        }
        if (!isInsideCache(file)) return PrepareResult.Rejected(RejectCode.SCHEME)
        return prepareFile(file)
    }

    fun isInsideCache(file: File): Boolean =
        file.path.startsWith(cacheRoot.path + File.separator)

    /** Checks and prepares [input] (inside `cacheDir`), then deletes it. */
    fun prepareFile(input: File): PrepareResult {
        var output: File? = null
        return try {
            checkAndWrite(input) { output = it }
        } catch (error: Throwable) {
            output?.delete()
            PrepareResult.Rejected(RejectCode.DECODE)
        } finally {
            deleteInput(input)
        }
    }

    private fun checkAndWrite(input: File, onOutput: (File) -> Unit): PrepareResult {
        if (!input.isFile) return PrepareResult.Rejected(RejectCode.FORMAT)
        if (input.length() > MAX_BYTES) return PrepareResult.Rejected(RejectCode.SIZE)
        val format = sniff(input) ?: return PrepareResult.Rejected(RejectCode.FORMAT)
        if (format == Format.HEIC && sdkInt < Build.VERSION_CODES.P) {
            return PrepareResult.Rejected(RejectCode.FORMAT)
        }
        val (width, height) = decoder.bounds(input.path)
        if (width <= 0 || height <= 0) return PrepareResult.Rejected(RejectCode.DECODE)
        if (width.toLong() * height > MAX_PIXELS) return PrepareResult.Rejected(RejectCode.SIZE)
        val decoded = decoder.decode(input.path, sampleSizeFor(maxOf(width, height)))
            ?: return PrepareResult.Rejected(RejectCode.DECODE)
        val prepared = orient(scale(decoded), orientationOf(input))
        labelDir.mkdirs()
        val target = File(labelDir, "${UUID.randomUUID()}.jpg")
        onOutput(target)
        FileOutputStream(target).use { stream ->
            if (!prepared.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, stream)) {
                throw IOException("JPEG not written")
            }
        }
        prepared.recycle()
        return PrepareResult.Ready(target.path)
    }

    /** Largest power of two n with longSide / n >= [TARGET_LONG_SIDE]. */
    fun sampleSizeFor(longSide: Int): Int {
        var sample = 1
        while (longSide / (sample * 2) >= TARGET_LONG_SIDE) sample *= 2
        return sample
    }

    private fun sniff(file: File): Format? {
        val header = ByteArray(HEADER_BYTES)
        val read = file.inputStream().use { it.read(header) }
        if (read < HEADER_BYTES) return null
        fun at(index: Int) = header[index].toInt() and 0xFF
        fun ascii(from: Int, to: Int) = String(header.copyOfRange(from, to), Charsets.US_ASCII)
        return when {
            at(0) == 0xFF && at(1) == 0xD8 && at(2) == 0xFF -> Format.JPEG
            at(0) == 0x89 && ascii(1, 4) == "PNG" && at(4) == 0x0D && at(5) == 0x0A -> Format.PNG
            ascii(0, 4) == "RIFF" && ascii(8, 12) == "WEBP" -> Format.WEBP
            ascii(4, 8) == "ftyp" && ascii(8, 12) in HEIC_BRANDS -> Format.HEIC
            else -> null
        }
    }

    private fun scale(bitmap: Bitmap): Bitmap {
        val longSide = maxOf(bitmap.width, bitmap.height)
        if (longSide <= TARGET_LONG_SIDE) return bitmap
        val ratio = TARGET_LONG_SIDE.toDouble() / longSide
        val width = maxOf(1, Math.round(bitmap.width * ratio).toInt())
        val height = maxOf(1, Math.round(bitmap.height * ratio).toInt())
        val scaled = Bitmap.createScaledBitmap(bitmap, width, height, true)
        if (scaled !== bitmap) bitmap.recycle()
        return scaled
    }

    private fun orientationOf(file: File): Int = try {
        ExifInterface(file.path).getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL,
        )
    } catch (error: Exception) {
        ExifInterface.ORIENTATION_NORMAL
    }

    private fun orient(bitmap: Bitmap, orientation: Int): Bitmap {
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.postScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> matrix.apply { postRotate(90f); postScale(-1f, 1f) }
            ExifInterface.ORIENTATION_TRANSVERSE -> matrix.apply { postRotate(270f); postScale(-1f, 1f) }
            else -> return bitmap
        }
        val oriented = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        if (oriented !== bitmap) bitmap.recycle()
        return oriented
    }

    /** Deletes [input] and, when image_picker left it in its own folder, that empty folder. */
    private fun deleteInput(input: File) {
        input.delete()
        val parent = try {
            input.parentFile?.canonicalFile
        } catch (error: IOException) {
            null
        } ?: return
        if (parent == cacheRoot || parent == canonicalLabelDir || !isInsideCache(parent)) return
        if (parent.list()?.isEmpty() == true) parent.delete()
    }
}

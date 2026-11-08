package com.vinoozy.vinoozy

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File

/**
 * "Apri in Google Lens" (label-recognition FR4.3, BR5.2, D4, NFR3.3,
 * NFR3.5, NFR4.10): shares the prepared front photo, and nothing else, with
 * the Google app; when the app is missing or refuses the intent, the system
 * share menu opens with the same photo, Vinoozy excluded.
 *
 * - The photo must be a file of `cacheDir/label/`; it leaves through the
 *   FileProvider of that folder only, with a temporary read permission
 *   (FLAG_GRANT_READ_URI_PERMISSION), never a write one.
 * - Nothing comes back: no result is read from Google (BR5.3).
 *
 * Returns "direct", "chooser" or "failed". The seams (uri, start, package
 * check) are replaced in the Robolectric test.
 *
 * label-autofill-windows adds "From Google Lens" ([openLensCamera], BR2.5,
 * FR2.6) and the copy time of the clipboard ([clipTimestamp], BR2.6,
 * NFR3.1), which never reads the copied content.
 */
class LensIntentLauncher(
    private val context: Context,
    private val labelDir: File,
    private val uriFor: (File) -> Uri = { file ->
        FileProvider.getUriForFile(context, authorityOf(context), file)
    },
    private val start: (Intent) -> Unit = { intent -> context.startActivity(intent) },
    private val hasPackage: (String) -> Boolean = { name -> isInstalled(context, name) },
    private val launchIntentFor: (String) -> Intent? = { name ->
        context.packageManager.getLaunchIntentForPackage(name)
    },
    private val clipDescription: () -> ClipDescription? = {
        (context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager)
            ?.primaryClipDescription
    },
    private val sdkInt: Int = Build.VERSION.SDK_INT,
    private val now: () -> Long = { System.currentTimeMillis() },
) {
    companion object {
        const val GOOGLE_PACKAGE = "com.google.android.googlequicksearchbox"
        const val DIRECT = "direct"
        const val CHOOSER = "chooser"
        const val FAILED = "failed"

        /** The Google Lens app (label-autofill-windows BR2.5). */
        const val LENS_PACKAGE = "com.google.ar.lens"

        /** The Lens screen of the Google app. */
        const val GOOGLE_LENS_URI = "googleapp://lens"

        /** Answers of [openLensCamera]. */
        const val LENS_APP = "lensApp"
        const val GOOGLE_APP = "googleApp"
        const val UNAVAILABLE = "unavailable"

        /** `ClipDescription.getTimestamp()` exists from Android 8.0. */
        const val MIN_CLIP_TIMESTAMP_SDK = 26

        /** Same as the `android:authorities` of the provider in the manifest. */
        fun authorityOf(context: Context): String = "${context.packageName}.labelfiles"

        private fun isInstalled(context: Context, name: String): Boolean = try {
            context.packageManager.getPackageInfo(name, 0)
            true
        } catch (error: PackageManager.NameNotFoundException) {
            false
        }
    }

    fun open(path: String): String {
        val file = labelFileOrNull(path) ?: return FAILED
        val uri = try {
            uriFor(file)
        } catch (error: IllegalArgumentException) {
            return FAILED
        }
        if (hasPackage(GOOGLE_PACKAGE)) {
            try {
                start(sendIntent(uri).setPackage(GOOGLE_PACKAGE))
                return DIRECT
            } catch (error: ActivityNotFoundException) {
                // The Google app does not take images: the share menu below.
            } catch (error: SecurityException) {
                // Same fallback.
            }
        }
        return try {
            start(chooserIntent(uri))
            CHOOSER
        } catch (error: RuntimeException) {
            FAILED
        }
    }

    /** ACTION_SEND of one JPEG with a temporary read grant (BR5.2). */
    fun sendIntent(uri: Uri): Intent = Intent(Intent.ACTION_SEND)
        .setType("image/jpeg")
        .putExtra(Intent.EXTRA_STREAM, uri)
        .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        .also { it.clipData = ClipData.newRawUri("", uri) }

    /** The share menu without Vinoozy itself (EXTRA_EXCLUDE_COMPONENTS). */
    fun chooserIntent(uri: Uri): Intent = Intent.createChooser(sendIntent(uri), null)
        .putExtra(
            Intent.EXTRA_EXCLUDE_COMPONENTS,
            arrayOf(ComponentName(context, MainActivity::class.java)),
        )
        .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

    /**
     * "From Google Lens" (BR2.5): the launch intent of the Lens app; when it
     * is missing or refused, the Lens screen of the Google app; otherwise
     * [UNAVAILABLE], and Dart shows the three steps. Returns the route and,
     * when Lens opened, the system time it opened (`openedAt`, BR2.6,
     * review R-08: wall clock, as the clip timestamp).
     */
    fun openLensCamera(): Map<String, Any> {
        val lens = try {
            launchIntentFor(LENS_PACKAGE)
        } catch (error: RuntimeException) {
            null
        }
        if (lens != null && tryStart(lens.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))) {
            return mapOf("route" to LENS_APP, "openedAt" to now())
        }
        if (tryStart(googleLensIntent())) {
            return mapOf("route" to GOOGLE_APP, "openedAt" to now())
        }
        return mapOf("route" to UNAVAILABLE)
    }

    /** The Lens screen of the Google app. */
    fun googleLensIntent(): Intent = Intent(Intent.ACTION_VIEW, Uri.parse(GOOGLE_LENS_URI))
        .setPackage(GOOGLE_PACKAGE)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    private fun tryStart(intent: Intent): Boolean = try {
        start(intent)
        true
    } catch (error: ActivityNotFoundException) {
        false
    } catch (error: SecurityException) {
        false
    }

    /**
     * The copy time and the first MIME type of the primary clip, read from
     * its description only: the copied content is never read here (BR2.6,
     * NFR3.1). `null` below Android 8.0 (no timestamp), without a clip, or
     * when the system refuses (no focus on Android 10+).
     */
    @SuppressLint("NewApi") // Guarded by [sdkInt], the seam of the test.
    fun clipTimestamp(): Map<String, Any>? {
        if (sdkInt < MIN_CLIP_TIMESTAMP_SDK) return null
        val description = try {
            clipDescription()
        } catch (error: RuntimeException) {
            null
        } ?: return null
        if (description.mimeTypeCount == 0) return null
        return mapOf(
            "timestamp" to description.timestamp,
            "mime" to description.getMimeType(0),
        )
    }

    /** [path] when it is an existing file directly inside the label folder. */
    private fun labelFileOrNull(path: String): File? = try {
        val file = File(path).canonicalFile
        if (file.isFile && file.parentFile == labelDir.canonicalFile) file else null
    } catch (error: java.io.IOException) {
        null
    }
}

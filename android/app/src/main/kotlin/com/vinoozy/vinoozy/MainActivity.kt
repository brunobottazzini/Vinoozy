package com.vinoozy.vinoozy

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * The only activity. Since u6-label-recognition it also hosts the label
 * channel (lib/label/platform/shared_image_channel.dart): image preparation
 * and the shared images, each on a background thread, results back on the
 * main thread (security-design.md §3).
 */
class MainActivity : FlutterActivity() {
    companion object {
        const val LABEL_CHANNEL = "com.vinoozy.app/label"

        /** "Apri in Google Lens" (label-recognition FR4.3, lens_channel.dart). */
        const val LENS_CHANNEL = "vinoozy/lens"
    }

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var preparer: LabelImagePreparer
    private lateinit var receiver: SharedImageReceiver
    private lateinit var lens: LensIntentLauncher
    private var channel: MethodChannel? = null
    private var lensChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before super.onCreate, which configures the engine and the channel.
        preparer = LabelImagePreparer(cacheDir)
        receiver = SharedImageReceiver(contentResolver, preparer)
        lens = LensIntentLauncher(this, File(cacheDir, LabelImagePreparer.LABEL_DIR_NAME))
        // A restored activity or one reopened from the recents gets the old
        // SEND intent back: it is not a new share (review R-03).
        receiver.onCreate(intent, restored = savedInstanceState != null) { setIntent(it) }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LABEL_CHANNEL).also {
            it.setMethodCallHandler(::onLabelCall)
        }
        lensChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LENS_CHANNEL).also {
            it.setMethodCallHandler(::onLensCall)
        }
    }

    /**
     * `open(path)`: only after the user's confirmation in Dart (BR5.1). The
     * answer is "direct", "chooser" or "failed"; nothing from Google comes
     * back (BR5.3, NFR3.5).
     *
     * label-autofill-windows: `openLensCamera` ("From Google Lens", BR2.5)
     * and `clipTimestamp` (copy time and MIME type of the clipboard, never
     * its content, BR2.6).
     */
    private fun onLensCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "open" -> {
                val path = call.argument<String>("path")
                result.success(if (path == null) LensIntentLauncher.FAILED else lens.open(path))
            }
            "openLensCamera" -> result.success(lens.openLensCamera())
            "clipTimestamp" -> result.success(lens.clipTimestamp())
            else -> result.notImplemented()
        }
    }

    /**
     * Android 10+ reads the clipboard only with the window focus, which may
     * come after the resume: Dart checks the automatic paste again on the
     * first focus (label-autofill-windows BR2.6, review R-08).
     */
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) lensChannel?.invokeMethod("windowFocused", null)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (receiver.onNewIntent(intent) { setIntent(it) }) {
            channel?.invokeMethod("shareArrived", receiver.pendingInfo())
        }
    }

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }

    private fun onLabelCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.success(PrepareResult.Rejected(RejectCode.SCHEME).toChannelMap())
                } else {
                    inBackground(result) { preparer.preparePickedPath(path) }
                }
            }
            "pendingShare" -> result.success(receiver.pendingInfo())
            "readShare" -> {
                val share = receiver.takePending()
                if (share == null) result.success(null) else inBackground(result) { receiver.read(share) }
            }
            "discardShare" -> {
                receiver.discard()
                result.success(null)
            }
            // label-autofill-windows FR2.1: the shared text, taken once.
            "readSharedText" -> result.success(receiver.takeText())
            "openSettings" -> result.success(openAppSettings())
            else -> result.notImplemented()
        }
    }

    private fun inBackground(result: MethodChannel.Result, work: () -> PrepareResult) {
        executor.execute {
            val outcome = try {
                work()
            } catch (error: Throwable) {
                PrepareResult.Rejected(RejectCode.DECODE)
            }
            mainHandler.post { result.success(outcome.toChannelMap()) }
        }
    }

    /** "Apri impostazioni" (BR1.5): the app details page of the system. */
    private fun openAppSettings(): Boolean = try {
        startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        true
    } catch (error: Exception) {
        false
    }
}

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
    }

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var preparer: LabelImagePreparer
    private lateinit var receiver: SharedImageReceiver
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before super.onCreate, which configures the engine and the channel.
        preparer = LabelImagePreparer(cacheDir)
        receiver = SharedImageReceiver(contentResolver, preparer)
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

package com.vinoozy.vinoozy

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The `com.vinoozy.app/links` channel (lib/app/external_links.dart). Links
 * stay restricted (tester-feedback NFR7):
 * - `open(url)`: an `https` page in the browser, nothing else;
 * - `email(subject, body)` (FR6.1, FR6.3): the email app with
 *   `ACTION_SENDTO` and `mailto:` to the fixed support address only; the
 *   recipient never comes from Dart. False when no app handles it;
 * - `deviceInfo` (FR6.1, review R-01): manufacturer, model and Android
 *   version for the end of the feedback email, read without a dependency.
 *
 * [start] starts an activity; the tests replace it.
 */
class LinksChannelHandler(private val start: (Intent) -> Unit) : MethodChannel.MethodCallHandler {
    companion object {
        /** Same value as `supportEmail` in lib/app/store_links.dart. */
        const val SUPPORT_EMAIL = "bottazzinibruno@gmail.com"

        /** The feedback email: `mailto:` to [SUPPORT_EMAIL], never another address. */
        fun supportEmailIntent(subject: String?, body: String?): Intent =
            // Uri.parse keeps the "@" as is (fromParts would encode it).
            Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$SUPPORT_EMAIL"))
                .putExtra(Intent.EXTRA_EMAIL, arrayOf(SUPPORT_EMAIL))
                .putExtra(Intent.EXTRA_SUBJECT, subject.orEmpty())
                .putExtra(Intent.EXTRA_TEXT, body.orEmpty())

        fun deviceInfo(): Map<String, String> = mapOf(
            "manufacturer" to Build.MANUFACTURER.orEmpty(),
            "model" to Build.MODEL.orEmpty(),
            "release" to Build.VERSION.RELEASE.orEmpty(),
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "open" -> result.success(openHttps(call.argument<String>("url")))
            "email" -> result.success(
                startOrFalse(supportEmailIntent(call.argument("subject"), call.argument("body"))),
            )
            "deviceInfo" -> result.success(deviceInfo())
            else -> result.notImplemented()
        }
    }

    private fun openHttps(url: String?): Boolean {
        val uri = url?.let(Uri::parse)
        if (uri?.scheme != "https" || uri.host.isNullOrBlank()) return false
        return startOrFalse(Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE))
    }

    /** No app for the intent (no browser, no email app) is a recoverable false. */
    private fun startOrFalse(intent: Intent): Boolean = try {
        start(intent)
        true
    } catch (error: ActivityNotFoundException) {
        false
    } catch (error: SecurityException) {
        false
    }
}

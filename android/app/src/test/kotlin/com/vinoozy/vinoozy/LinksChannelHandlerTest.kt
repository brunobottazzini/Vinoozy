package com.vinoozy.vinoozy

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * LinksChannelHandler (tester-feedback FR6.1, FR6.3, NFR7): the feedback
 * email goes only to the fixed support address, "no email app" is false,
 * `open` still refuses anything but https, `deviceInfo` and `supportEmail`
 * answer.
 * The start of the activity is replaced: no real app is opened.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class LinksChannelHandlerTest {
    private val started = mutableListOf<Intent>()
    private var failStart = false

    private fun handler() = LinksChannelHandler { intent ->
        if (failStart) throw ActivityNotFoundException("none")
        started += intent
    }

    private class Captured : MethodChannel.Result {
        var value: Any? = null
        var notImplemented = false
        override fun success(result: Any?) { value = result }
        override fun error(code: String, message: String?, details: Any?) {}
        override fun notImplemented() { notImplemented = true }
    }

    private fun call(method: String, args: Map<String, Any?>? = null): Captured =
        Captured().also { handler().onMethodCall(MethodCall(method, args), it) }

    @Test
    fun emailGoesOnlyToTheSupportAddress() {
        val result = call("email", mapOf("subject" to "Feedback", "body" to "Hello"))
        assertEquals(true, result.value)
        val intent = started.single()
        assertEquals(Intent.ACTION_SENDTO, intent.action)
        assertEquals("mailto:bottazzinibruno@gmail.com", intent.data.toString())
        assertArrayEquals(arrayOf("bottazzinibruno@gmail.com"), intent.getStringArrayExtra(Intent.EXTRA_EMAIL))
        assertEquals("Feedback", intent.getStringExtra(Intent.EXTRA_SUBJECT))
        assertEquals("Hello", intent.getStringExtra(Intent.EXTRA_TEXT))
    }

    @Test
    fun aRecipientFromDartIsIgnored() {
        call("email", mapOf("subject" to "x", "body" to "y", "to" to "someone@example.com"))
        assertEquals("mailto:bottazzinibruno@gmail.com", started.single().data.toString())
    }

    @Test
    fun noEmailAppIsFalse() {
        failStart = true
        assertEquals(false, call("email", mapOf("subject" to "x", "body" to "y")).value)
    }

    @Test
    fun openRefusesEverythingButHttps() {
        for (url in listOf("mailto:a@b.c", "market://details?id=x", "http://example.com", "https:", null)) {
            assertEquals(url, false, call("open", mapOf("url" to url)).value)
        }
        assertTrue(started.isEmpty())
        assertEquals(true, call("open", mapOf("url" to "https://example.com")).value)
        assertEquals(Intent.ACTION_VIEW, started.single().action)
    }

    @Test
    fun supportEmailAnswersTheFixedAddressWithoutStartingAnything() {
        val result = call("supportEmail")
        assertEquals("bottazzinibruno@gmail.com", result.value)
        assertEquals(LinksChannelHandler.SUPPORT_EMAIL, result.value)
        assertTrue(started.isEmpty())
    }

    @Test
    fun deviceInfoAndUnknownMethods() {
        @Suppress("UNCHECKED_CAST")
        val info = call("deviceInfo").value as Map<String, String>
        assertEquals(setOf("manufacturer", "model", "release"), info.keys)
        assertTrue(call("share").notImplemented)
    }
}

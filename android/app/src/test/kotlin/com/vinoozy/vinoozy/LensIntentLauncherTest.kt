package com.vinoozy.vinoozy

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.ClipDescription
import android.content.Intent
import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.File

/**
 * LensIntentLauncher (label-recognition FR4.3, BR5.2, NFR3.3, NFR4.10): the
 * intent to the Google app, the share menu as fallback, and nothing shared
 * from outside cacheDir/label/. The FileProvider uri, the start of the
 * activity and the package check are replaced: no real app is opened.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class LensIntentLauncherTest {
    @get:Rule
    val temp = TemporaryFolder()

    private lateinit var labelDir: File
    private lateinit var photo: File
    private val started = mutableListOf<Intent>()
    private var googleInstalled = true
    private var failDirect = false
    private var failChooser = false

    @Before
    fun setUp() {
        labelDir = temp.newFolder("cache", "label")
        photo = File(labelDir, "front.jpg").apply { writeBytes(byteArrayOf(1, 2, 3)) }
    }

    private fun launcher() = LensIntentLauncher(
        context = ApplicationProvider.getApplicationContext(),
        labelDir = labelDir,
        uriFor = { Uri.parse("content://com.vinoozy.app.labelfiles/label/${it.name}") },
        start = { intent ->
            val isChooser = intent.action == Intent.ACTION_CHOOSER
            if (!isChooser && failDirect) throw ActivityNotFoundException()
            if (isChooser && failChooser) throw ActivityNotFoundException()
            started += intent
        },
        hasPackage = { googleInstalled },
    )

    @Test
    fun withTheGoogleAppTheFrontGoesStraightToIt() {
        assertEquals("direct", launcher().open(photo.path))
        val intent = started.single()
        assertEquals(Intent.ACTION_SEND, intent.action)
        assertEquals(LensIntentLauncher.GOOGLE_PACKAGE, intent.`package`)
        assertEquals("image/jpeg", intent.type)
        @Suppress("DEPRECATION")
        val stream = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        assertEquals("content://com.vinoozy.app.labelfiles/label/front.jpg", stream.toString())
        assertEquals(stream, intent.clipData!!.getItemAt(0).uri)
        assertTrue(intent.flags and Intent.FLAG_GRANT_READ_URI_PERMISSION != 0)
        assertTrue(intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION == 0)
    }

    @Test
    fun withoutTheGoogleAppTheShareMenuOpensWithoutVinoozy() {
        googleInstalled = false
        assertEquals("chooser", launcher().open(photo.path))
        val chooser = started.single()
        assertEquals(Intent.ACTION_CHOOSER, chooser.action)
        @Suppress("DEPRECATION")
        val excluded = chooser.getParcelableArrayExtra(Intent.EXTRA_EXCLUDE_COMPONENTS)!!
        assertEquals(MainActivity::class.java.name, (excluded.single() as android.content.ComponentName).className)
        @Suppress("DEPRECATION")
        val inner = chooser.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)!!
        assertNull(inner.`package`)
        assertTrue(inner.flags and Intent.FLAG_GRANT_READ_URI_PERMISSION != 0)
    }

    @Test
    fun anActivityNotFoundFallsBackToTheShareMenu() {
        failDirect = true
        assertEquals("chooser", launcher().open(photo.path))
        assertEquals(Intent.ACTION_CHOOSER, started.single().action)
    }

    @Test
    fun whenTheShareMenuFailsTooTheAnswerIsFailed() {
        failDirect = true
        failChooser = true
        assertEquals("failed", launcher().open(photo.path))
        assertTrue(started.isEmpty())
    }

    // ---- label-autofill-windows BR2.5, BR2.6, NFR3.1 -------------------

    private var lensIntent: Intent? = Intent(Intent.ACTION_MAIN).setPackage(LensIntentLauncher.LENS_PACKAGE)
    private var refused = mutableSetOf<String>()
    private var description: ClipDescription? = null
    private var sdk = 34

    private fun cameraLauncher() = LensIntentLauncher(
        context = ApplicationProvider.getApplicationContext(),
        labelDir = labelDir,
        start = { intent ->
            if (refused.contains(intent.`package`)) throw ActivityNotFoundException()
            started += intent
        },
        launchIntentFor = { lensIntent },
        clipDescription = { description },
        sdkInt = sdk,
        now = { 1_700_000_000_000L },
    )

    @Test
    fun theLensAppOpensFirstWithItsOpeningTime() {
        val result = cameraLauncher().openLensCamera()
        assertEquals("lensApp", result["route"])
        assertEquals(1_700_000_000_000L, result["openedAt"])
        assertEquals(LensIntentLauncher.LENS_PACKAGE, started.single().`package`)
        assertTrue(started.single().flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0)
    }

    @Test
    fun withoutTheLensAppTheGoogleAppLensOpens() {
        lensIntent = null
        val result = cameraLauncher().openLensCamera()
        assertEquals("googleApp", result["route"])
        val intent = started.single()
        assertEquals(Intent.ACTION_VIEW, intent.action)
        assertEquals("googleapp://lens", intent.data.toString())
        assertEquals(LensIntentLauncher.GOOGLE_PACKAGE, intent.`package`)
    }

    @Test
    fun whenBothRefuseTheAnswerIsUnavailableWithoutATime() {
        refused = mutableSetOf(LensIntentLauncher.LENS_PACKAGE, LensIntentLauncher.GOOGLE_PACKAGE)
        val result = cameraLauncher().openLensCamera()
        assertEquals(mapOf("route" to "unavailable"), result)
        assertTrue(started.isEmpty())
    }

    @Test
    fun aRefusedLensAppFallsBackToTheGoogleApp() {
        refused = mutableSetOf(LensIntentLauncher.LENS_PACKAGE)
        assertEquals("googleApp", cameraLauncher().openLensCamera()["route"])
    }

    @Test
    fun theClipTimestampAndMimeComeFromTheDescriptionOnly() {
        description = ClipDescription("label", arrayOf("text/plain")).apply {
            org.robolectric.util.ReflectionHelpers.setField(this, "mTimeStamp", 1_700_000_100_000L)
        }
        val result = cameraLauncher().clipTimestamp()!!
        assertEquals(1_700_000_100_000L, result["timestamp"])
        assertEquals("text/plain", result["mime"])
    }

    @Test
    fun belowAndroid8OrWithoutAClipThereIsNoTimestamp() {
        description = ClipDescription("label", arrayOf("text/plain"))
        sdk = 25
        assertNull(cameraLauncher().clipTimestamp())
        sdk = 34
        description = null
        assertNull(cameraLauncher().clipTimestamp())
        description = ClipDescription("label", arrayOf())
        assertNull(cameraLauncher().clipTimestamp())
    }

    @Test
    fun aFileOutsideTheLabelFolderOrMissingIsNeverShared() {
        val outside = temp.newFile("gallery.jpg")
        assertEquals("failed", launcher().open(outside.path))
        assertEquals("failed", launcher().open(File(labelDir, "missing.jpg").path))
        assertEquals("failed", launcher().open("${labelDir.path}/../gallery.jpg"))
        assertTrue(started.isEmpty())
    }
}

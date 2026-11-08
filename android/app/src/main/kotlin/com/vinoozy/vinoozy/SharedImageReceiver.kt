package com.vinoozy.vinoozy

import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import java.io.File
import java.util.UUID

/** A share kept in memory until Dart asks to read it (u6 NFR4.5). */
sealed class PendingShare {
    abstract val multiple: Boolean

    /** Only the URI, never a copy: the copy starts when the reading does. */
    data class Image(val uri: Uri, override val multiple: Boolean) : PendingShare()

    /** Refused at reception; Dart shows "unreadable" with label_pick_failed. */
    data class Refused(val code: String, override val multiple: Boolean) : PendingShare()

    /**
     * Text shared by Google Lens (label-autofill-windows FR2.1, BR2.3): in
     * memory only, at most [SharedImageReceiver.MAX_TEXT_CHARS] characters,
     * never written to a file nor logged. Its string form hides it.
     */
    class Text(val text: String) : PendingShare() {
        override val multiple: Boolean get() = false

        override fun toString(): String = "Text(${text.length} chars)"
    }
}

/**
 * Receives "Share -> Vinoozy" (u6-label-recognition BR1.4, NFR4.4, NFR4.5,
 * security-design.md §3).
 *
 * At reception (main thread): only `ACTION_SEND` and `ACTION_SEND_MULTIPLE`
 * with a declared `image/` type and a `content://` URI; with several images
 * only the first is kept, the others are never opened. The intent is then
 * consumed (replaced with an empty one) so a rotation or a return to the app
 * does not show the same share again; a new share replaces the previous one.
 *
 * At reading (background thread, [read]): the first URI is copied in 64 KB
 * chunks into `cacheDir/label/`, the copy stops and is deleted beyond 20 MB
 * read whatever size was declared, then [LabelImagePreparer] checks and
 * prepares it.
 */
class SharedImageReceiver(
    private val resolver: ContentResolver,
    private val preparer: LabelImagePreparer,
) {
    companion object {
        const val COPY_CHUNK_BYTES = 64 * 1024

        /** The longest shared text kept (label-autofill-windows BR2.3). */
        const val MAX_TEXT_CHARS = 4000

        /** [text] cut to [MAX_TEXT_CHARS], never in the middle of a pair. */
        fun clampText(text: String): String {
            if (text.length <= MAX_TEXT_CHARS) return text
            val end = if (Character.isHighSurrogate(text[MAX_TEXT_CHARS - 1])) {
                MAX_TEXT_CHARS - 1
            } else {
                MAX_TEXT_CHARS
            }
            return text.substring(0, end)
        }
    }

    @Volatile
    private var pending: PendingShare? = null

    val hasPending: Boolean get() = pending != null

    /**
     * The share in the intent that started the activity. When the activity is
     * restored ([restored], a non-null savedInstanceState) or reopened from
     * the recents (FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY), Android hands back
     * the original SEND intent: that old share is consumed and ignored, never
     * read again (review R-03).
     */
    fun onCreate(intent: Intent?, restored: Boolean, replaceIntent: (Intent) -> Unit): Boolean {
        val fromHistory = intent != null &&
            (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (restored || fromHistory) {
            if (isShare(intent)) replaceIntent(Intent())
            return false
        }
        return take(intent, replaceIntent)
    }

    private fun isShare(intent: Intent?): Boolean =
        intent?.action == Intent.ACTION_SEND || intent?.action == Intent.ACTION_SEND_MULTIPLE

    /** A share while the app runs; true when Dart must be told. */
    fun onNewIntent(intent: Intent?, replaceIntent: (Intent) -> Unit): Boolean =
        take(intent, replaceIntent)

    /**
     * What Dart sees of the pending share: whether there were several images
     * and, since label-autofill-windows, whether it is a text; never the
     * text itself, read only by [takeText].
     */
    fun pendingInfo(): Map<String, Any>? = pending?.let {
        mapOf("multiple" to it.multiple, "kind" to if (it is PendingShare.Text) "text" else "image")
    }

    /** The shared text, taken out once; `null` when the share is not a text. */
    fun takeText(): String? {
        val share = pending as? PendingShare.Text ?: return null
        pending = null
        return share.text
    }

    /** Drops the reference (no sign-in, no permission, expired, replaced). */
    fun discard() {
        pending = null
    }

    /** Takes the pending share out, on the main thread, before [read] runs. */
    fun takePending(): PendingShare? = pending.also { pending = null }

    /** Copies and prepares a taken share; call it on a background thread. */
    fun read(share: PendingShare): PrepareResult = when (share) {
        is PendingShare.Refused -> PrepareResult.Rejected(share.code)
        is PendingShare.Image -> copyAndPrepare(share.uri)
        // A text is read by takeText, never prepared as an image.
        is PendingShare.Text -> PrepareResult.Rejected(RejectCode.TYPE)
    }

    private fun take(intent: Intent?, replaceIntent: (Intent) -> Unit): Boolean {
        if (intent == null || !isShare(intent)) return false
        replaceIntent(Intent())
        val type = intent.type
        if (intent.action == Intent.ACTION_SEND && type == "text/plain") {
            // label-autofill-windows FR2.1: only the text extra, cut at once;
            // an empty text is kept so Dart can say "No text received".
            val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString() ?: ""
            pending = PendingShare.Text(clampText(text))
            return true
        }
        val uris = streamsOf(intent)
        val multiple = uris.size > 1
        val first = uris.firstOrNull()
        pending = when {
            type == null || !type.startsWith("image/") -> PendingShare.Refused(RejectCode.TYPE, multiple)
            first == null || first.scheme != ContentResolver.SCHEME_CONTENT ->
                PendingShare.Refused(RejectCode.SCHEME, multiple)
            else -> PendingShare.Image(first, multiple)
        }
        return true
    }

    @Suppress("DEPRECATION")
    private fun streamsOf(intent: Intent): List<Uri> = when (intent.action) {
        Intent.ACTION_SEND -> listOfNotNull(intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri)
        else -> intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.filterNotNull().orEmpty()
    }

    private fun copyAndPrepare(uri: Uri): PrepareResult {
        val declared = try {
            resolver.getType(uri)
        } catch (error: Exception) {
            null
        }
        if (declared != null && !declared.startsWith("image/")) {
            return PrepareResult.Rejected(RejectCode.TYPE)
        }
        val copy = File(preparer.labelDir, "${UUID.randomUUID()}.share")
        return try {
            preparer.labelDir.mkdirs()
            if (!copyLimited(uri, copy)) {
                copy.delete()
                return PrepareResult.Rejected(RejectCode.SIZE)
            }
            preparer.prepareFile(copy)
        } catch (error: Throwable) {
            copy.delete()
            PrepareResult.Rejected(RejectCode.DECODE)
        }
    }

    /** False when more than 20 MB were read; the caller deletes the copy. */
    private fun copyLimited(uri: Uri, target: File): Boolean {
        val input = resolver.openInputStream(uri) ?: throw IllegalStateException("no stream")
        input.use { source ->
            target.outputStream().use { sink ->
                val buffer = ByteArray(COPY_CHUNK_BYTES)
                var total = 0L
                while (true) {
                    val read = source.read(buffer)
                    if (read < 0) return true
                    total += read
                    if (total > LabelImagePreparer.MAX_BYTES) return false
                    sink.write(buffer, 0, read)
                }
            }
        }
    }
}

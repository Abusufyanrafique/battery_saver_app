package com.example.battery_saver_app

import android.app.ActivityManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class JunkScannerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.example.battery_saver_app/junk_scanner")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val value = when (call.method) {
                    "getCacheSize"     -> getCacheSize()
                    "getResidualSize"  -> getResidualSize()
                    "getApkSize"       -> getApkSize()
                    "getTrackedSize"   -> getTrackedSize()
                    "getMemoryInfo"    -> getMemoryInfo()
                    "scanAll"          -> scanAll()
                    "cleanCache"       -> cleanCache()
                    "cleanResidual"    -> cleanResidual()
                    "cleanApk"         -> cleanApk()
                    "cleanTracked"     -> cleanTracked()
                    else               -> throw UnsupportedOperationException("Unknown method: ${call.method}")
                }
                withContext(Dispatchers.Main) { result.success(value) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("JUNK_ERROR", e.message, null)
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // CACHE — App internal + external cache
    // ─────────────────────────────────────────────
    private fun getCacheSize(): Long {
        var total = 0L
        total += dirSize(context.cacheDir)
        context.externalCacheDir?.let { total += dirSize(it) }
        return total
    }

    private fun cleanCache() {
        deleteDir(context.cacheDir)
        context.externalCacheDir?.let { deleteDir(it) }
    }

    // ─────────────────────────────────────────────
    // RESIDUAL — .log / .tmp / .bak / .old files
    // in filesDir + externalFilesDirs
    // ─────────────────────────────────────────────
    private val residualExts = listOf(".log", ".tmp", ".bak", ".old", ".temp", ".crash")

    private fun getResidualSize(): Long {
        var total = 0L
        val dirs = mutableListOf<File>(context.filesDir)
        context.getExternalFilesDirs(null).filterNotNull().forEach { dirs.add(it) }

        for (dir in dirs) {
            dir.walkTopDown().forEach { file ->
                if (file.isFile && residualExts.any { file.name.endsWith(it, ignoreCase = true) }) {
                    total += file.length()
                }
            }
        }
        return total
    }

    private fun cleanResidual() {
        val dirs = mutableListOf<File>(context.filesDir)
        context.getExternalFilesDirs(null).filterNotNull().forEach { dirs.add(it) }

        for (dir in dirs) {
            dir.walkTopDown().forEach { file ->
                if (file.isFile && residualExts.any { file.name.endsWith(it, ignoreCase = true) }) {
                    file.delete()
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // APK — MediaStore query (no root needed)
    // ─────────────────────────────────────────────
    private fun getApkSize(): Long {
        var total = 0L
        try {
            val uri = MediaStore.Files.getContentUri("external")
            val projection = arrayOf(
                MediaStore.Files.FileColumns.SIZE,
                MediaStore.Files.FileColumns.DATA
            )
            val selection = "${MediaStore.Files.FileColumns.DATA} LIKE ?"
            val selectionArgs = arrayOf("%.apk")

            context.contentResolver.query(uri, projection, selection, selectionArgs, null)?.use { cursor ->
                val sizeCol = cursor.getColumnIndex(MediaStore.Files.FileColumns.SIZE)
                while (cursor.moveToNext()) {
                    if (sizeCol != -1) total += cursor.getLong(sizeCol)
                }
            }
        } catch (e: Exception) {
            // Fallback: manual Downloads scan
            val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            downloads?.walkTopDown()?.forEach { file ->
                if (file.isFile && file.name.endsWith(".apk", ignoreCase = true)) {
                    total += file.length()
                }
            }
        }
        return total
    }

    private fun cleanApk() {
        try {
            val uri = MediaStore.Files.getContentUri("external")
            val projection = arrayOf(MediaStore.Files.FileColumns.DATA)
            val selection = "${MediaStore.Files.FileColumns.DATA} LIKE ?"
            val selectionArgs = arrayOf("%.apk")

            context.contentResolver.query(uri, projection, selection, selectionArgs, null)?.use { cursor ->
                val dataCol = cursor.getColumnIndex(MediaStore.Files.FileColumns.DATA)
                while (cursor.moveToNext()) {
                    if (dataCol != -1) {
                        File(cursor.getString(dataCol)).delete()
                    }
                }
            }
        } catch (_: Exception) {}
    }

    // ─────────────────────────────────────────────
    // TRACKED FILES — OUR OWN app's analytics/ad dirs
    // + installed apps ke known tracker folder names
    // (sandbox mein sirf apna accessible hai — honest label)
    // ─────────────────────────────────────────────
    private val trackedKeywords = listOf(
        "ads", "ad_cache", "analytics", "tracking",
        "mraid", "crashlytics", "metrics", "telemetry"
    )

    private fun getTrackedSize(): Long {
        var total = 0L
        val dirs = mutableListOf<File>()
        dirs.add(context.filesDir)
        dirs.add(context.cacheDir)
        context.getExternalFilesDirs(null).filterNotNull().forEach { dirs.add(it) }

        for (root in dirs) {
            root.walkTopDown().forEach { entity ->
                if (entity.isDirectory) {
                    val name = entity.name.lowercase()
                    if (trackedKeywords.any { name.contains(it) }) {
                        total += dirSize(entity)
                    }
                }
            }
        }
        return total
    }

    private fun cleanTracked() {
        val dirs = mutableListOf<File>()
        dirs.add(context.filesDir)
        dirs.add(context.cacheDir)
        context.getExternalFilesDirs(null).filterNotNull().forEach { dirs.add(it) }

        for (root in dirs) {
            root.walkTopDown().forEach { entity ->
                if (entity.isDirectory) {
                    val name = entity.name.lowercase()
                    if (trackedKeywords.any { name.contains(it) }) {
                        deleteDir(entity)
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // MEMORY INFO — Real RAM via ActivityManager
    // ─────────────────────────────────────────────
    private fun getMemoryInfo(): Map<String, Long> {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)

        return mapOf(
            "totalRam"     to info.totalMem,
            "availableRam" to info.availMem,
            "usedRam"      to (info.totalMem - info.availMem),
            "threshold"    to info.threshold,   // low memory threshold
            "isLowMemory"  to if (info.lowMemory) 1L else 0L
        )
    }

    // ─────────────────────────────────────────────
    // SCAN ALL — returns map of bytes per category
    // ─────────────────────────────────────────────
    private fun scanAll(): Map<String, Long> {
        val memInfo = getMemoryInfo()
        return mapOf(
            "cacheBytes"    to getCacheSize(),
            "residualBytes" to getResidualSize(),
            "apkBytes"      to getApkSize(),
            "trackedBytes"  to getTrackedSize(),
            "usedRam"       to (memInfo["usedRam"] ?: 0L),
            "totalRam"      to (memInfo["totalRam"] ?: 0L),
            "availableRam"  to (memInfo["availableRam"] ?: 0L),
        )
    }

    // ─────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────
    private fun dirSize(dir: File): Long {
        if (!dir.exists()) return 0L
        var size = 0L
        dir.walkTopDown().forEach { if (it.isFile) size += it.length() }
        return size
    }

    private fun deleteDir(dir: File) {
        if (!dir.exists()) return
        dir.walkTopDown().forEach { file ->
            try { file.delete() } catch (_: Exception) {}
        }
    }
}
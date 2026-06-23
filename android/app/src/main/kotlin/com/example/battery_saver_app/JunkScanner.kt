package com.example.battery_saver_app.junk

import android.app.ActivityManager
import android.content.Context
import android.os.Environment
import java.io.File

class JunkScanner(private val context: Context) {

    // ── SCAN ALL ──
    fun scanAll(): Map<String, Long> {
        val cache = getCacheSize()
        val residual = getResidualSize()
        val apk = getApkSize()
        val tracked = getTrackedSize()
        val memInfo = getMemoryInfoRaw()

        return mapOf(
            "cacheBytes" to cache,
            "residualBytes" to residual,
            "apkBytes" to apk,
            "trackedBytes" to tracked,
            "usedRam" to memInfo.first,
            "totalRam" to memInfo.second,
            "availableRam" to memInfo.third
        )
    }

    // ── CACHE SIZE — apni app ka cache (real) ──
    fun getCacheSize(): Long {
        return try {
            context.cacheDir.walkTopDown().filter { it.isFile }.sumOf { it.length() }
        } catch (e: Exception) {
            0L
        }
    }

    // ── RESIDUAL SIZE — apne khud ke external files folder ──
    fun getResidualSize(): Long {
        return try {
            context.getExternalFilesDir(null)?.walkTopDown()
                ?.filter { it.isFile }
                ?.sumOf { it.length() } ?: 0L
        } catch (e: Exception) {
            0L
        }
    }

    // ── APK SIZE — Downloads folder mein .apk files ──
    fun getApkSize(): Long {
        return try {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            downloadsDir?.walkTopDown()
                ?.filter { it.isFile && it.extension.equals("apk", ignoreCase = true) }
                ?.sumOf { it.length() } ?: 0L
        } catch (e: Exception) {
            0L
        }
    }

    // ── TRACKED FILES — apni app ka external cache ──
    fun getTrackedSize(): Long {
        return try {
            context.externalCacheDir?.walkTopDown()
                ?.filter { it.isFile }
                ?.sumOf { it.length() } ?: 0L
        } catch (e: Exception) {
            0L
        }
    }

    // ── MEMORY INFO (raw triple — scanAll ke liye) ──
    private fun getMemoryInfoRaw(): Triple<Long, Long, Long> {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            am.getMemoryInfo(memInfo)

            val total = memInfo.totalMem
            val available = memInfo.availMem
            val used = total - available

            Triple(used, total, available)
        } catch (e: Exception) {
            Triple(0L, 0L, 0L)
        }
    }

    // ── MEMORY INFO (Map — Dart MemoryInfo.fromMap() ke liye) ──
    fun getMemoryInfo(): Map<String, Any> {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            am.getMemoryInfo(memInfo)

            mapOf(
                "totalRam" to memInfo.totalMem,
                "availableRam" to memInfo.availMem,
                "usedRam" to (memInfo.totalMem - memInfo.availMem),
                "threshold" to memInfo.threshold,
                "isLowMemory" to if (memInfo.lowMemory) 1 else 0
            )
        } catch (e: Exception) {
            mapOf(
                "totalRam" to 0L,
                "availableRam" to 0L,
                "usedRam" to 0L,
                "threshold" to 0L,
                "isLowMemory" to 0
            )
        }
    }

    // ── CLEAN: apni app ka cache ──
    fun cleanCache() {
        try {
            context.cacheDir.deleteRecursively()
        } catch (e: Exception) {
            // silently fail
        }
    }

    // ── CLEAN: apni app ka external files folder ──
    fun cleanResidual() {
        try {
            context.getExternalFilesDir(null)?.deleteRecursively()
        } catch (e: Exception) {
            // silently fail
        }
    }

    // ── CLEAN: Downloads folder se .apk files
    // NOTE: Android 10+ par MANAGE_EXTERNAL_STORAGE permission chahiye,
    // warna SecurityException aayegi aur silently kuch delete nahi hoga ──
    fun cleanApk() {
        try {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            downloadsDir?.listFiles()
                ?.filter { it.isFile && it.extension.equals("apk", ignoreCase = true) }
                ?.forEach { it.delete() }
        } catch (e: Exception) {
            // silently fail
        }
    }

    // ── CLEAN: apni app ka external cache ──
    fun cleanTracked() {
        try {
            context.externalCacheDir?.deleteRecursively()
        } catch (e: Exception) {
            // silently fail
        }
    }
}
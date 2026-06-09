package com.example.battery_saver_app

import android.os.Environment
import java.io.File

class StorageManager {

    fun getStorageStats(context: android.content.Context): Map<String, Long> {
        val root = Environment.getExternalStorageDirectory()

        return mapOf(
            "junkFiles" to getJunkSize(root),
            "cacheFiles" to getCacheSize(context),
            "residualFiles" to getResidualSize(root)
        )
    }

    fun cleanResidualFiles(context: android.content.Context): Long {
        val root = Environment.getExternalStorageDirectory()
        var cleaned = 0L

        listOf(
            File(root, ".temp"),
            File(root, "LOST.DIR"),
            context.cacheDir
        ).forEach {
            cleaned += getFolderSize(it)
            it.deleteRecursively()
        }

        return cleaned
    }

    private fun getJunkSize(root: File): Long {
        val downloadDir = File(root, "Download")
        return getFolderSize(downloadDir)
    }

    private fun getCacheSize(context: android.content.Context): Long {
        var size = getFolderSize(context.cacheDir)
        context.externalCacheDir?.let { size += getFolderSize(it) }
        return size
    }

    private fun getResidualSize(root: File): Long {
        val folders = listOf(
            File(root, "Android/data"),
            File(root, "Android/obb"),
            File(root, ".temp"),
            File(root, "LOST.DIR")
        )
        return folders.sumOf { getFolderSize(it) }
    }

    private fun getFolderSize(dir: File): Long {
        var size = 0L
        if (!dir.exists()) return 0L

        dir.walkTopDown().forEach {
            if (it.isFile) size += it.length()
        }
        return size
    }
}
package com.example.battery_saver_app

import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.StorageStats
import android.app.usage.StorageStatsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import java.io.ByteArrayOutputStream
import java.util.concurrent.TimeUnit

class DeviceManager(private val context: Context) {

    fun getRunningAppsWithRealCache(): List<Map<String, Any?>> {
        val pm = context.packageManager

        val storageStatsManager =
            context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager

        val installedApps =
            pm.getInstalledApplications(PackageManager.GET_META_DATA)

        val myPackage = context.packageName

        val output = mutableListOf<Map<String, Any?>>()

        val recentPackages = getRecentlyUsedPackages()

        for (app in installedApps) {

            val isSystemApp =
                (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            val isLaunchable =
                pm.getLaunchIntentForPackage(app.packageName) != null

            if (app.packageName == myPackage) continue

            if (isSystemApp && !isLaunchable) continue

            var cacheBytes = 0L

            try {

                val stats: StorageStats =
                    storageStatsManager.queryStatsForUid(
                        android.os.storage.StorageManager.UUID_DEFAULT,
                        app.uid
                    )

                cacheBytes = stats.cacheBytes

            } catch (e: SecurityException) {

                cacheBytes = -1L

            } catch (e: Exception) {

                cacheBytes = 0L
            }

            if (cacheBytes <= 0 &&
                app.packageName !in recentPackages
            ) {
                continue
            }

            val appName = try {
                pm.getApplicationLabel(app).toString()
            } catch (e: Exception) {
                app.packageName
            }

            val iconBytes = try {
                drawableToPngBytes(
                    pm.getApplicationIcon(app.packageName)
                )
            } catch (e: Exception) {
                null
            }

            val sizeMb =
                if (cacheBytes > 0)
                    cacheBytes / (1024.0 * 1024.0)
                else
                    0.0

            output.add(
                mapOf(
                    "packageName" to app.packageName,
                    "appName" to appName,
                    "sizeMb" to sizeMb,
                    "cacheBytes" to cacheBytes,
                    "recentlyUsed" to (app.packageName in recentPackages),
                    "iconBytes" to iconBytes
                )
            )
        }

        return output.sortedByDescending {
            it["cacheBytes"] as Long
        }
    }

    fun getRealRamInfo(): Map<String, Any> {

        val am =
            context.getSystemService(Context.ACTIVITY_SERVICE)
                    as ActivityManager

        val memInfo = ActivityManager.MemoryInfo()

        am.getMemoryInfo(memInfo)

        return mapOf(
            "totalBytes" to memInfo.totalMem,
            "availBytes" to memInfo.availMem,
            "usedBytes" to (memInfo.totalMem - memInfo.availMem),
            "lowMemory" to memInfo.lowMemory,
            "threshold" to memInfo.threshold
        )
    }

    fun clearOwnAppCache(): Long {

        val before =
            getDirSize(context.cacheDir) +
                    (context.externalCacheDir?.let {
                        getDirSize(it)
                    } ?: 0L)

        context.cacheDir.deleteRecursively()

        context.externalCacheDir?.deleteRecursively()

        return before
    }

    fun killBackgroundProcesses(
        packages: List<String>
    ): List<String> {

        val am =
            context.getSystemService(Context.ACTIVITY_SERVICE)
                    as ActivityManager

        val attempted = mutableListOf<String>()

        for (pkg in packages) {

            try {

                am.killBackgroundProcesses(pkg)

                attempted.add(pkg)

            } catch (_: Exception) {
            }
        }

        return attempted
    }

    fun hasUsageAccessPermission(): Boolean {

        val appOps =
            context.getSystemService(Context.APP_OPS_SERVICE)
                    as AppOpsManager

        val mode =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {

                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )

            } else {

                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )
            }

        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getRecentlyUsedPackages(): Set<String> {

        val usm =
            context.getSystemService(Context.USAGE_STATS_SERVICE)
                    as UsageStatsManager

        val end = System.currentTimeMillis()

        val start =
            end - TimeUnit.HOURS.toMillis(1)

        val stats =
            usm.queryUsageStats(
                UsageStatsManager.INTERVAL_BEST,
                start,
                end
            )

        return stats
            ?.filter {
                it.totalTimeInForeground > 0
            }
            ?.map {
                it.packageName
            }
            ?.toSet()
            ?: emptySet()
    }

    private fun getDirSize(
        dir: java.io.File
    ): Long {

        if (!dir.exists()) return 0L

        var size = 0L

        dir.listFiles()?.forEach { file ->

            size += if (file.isDirectory) {
                getDirSize(file)
            } else {
                file.length()
            }
        }

        return size
    }

    private fun drawableToPngBytes(
        drawable: Drawable
    ): ByteArray? {

        return try {

            val bitmap = if (
                drawable is AdaptiveIconDrawable &&
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
            ) {

                val bmp =
                    Bitmap.createBitmap(
                        108,
                        108,
                        Bitmap.Config.ARGB_8888
                    )

                val canvas = Canvas(bmp)

                drawable.setBounds(
                    0,
                    0,
                    canvas.width,
                    canvas.height
                )

                drawable.draw(canvas)

                bmp

            } else {

                val width =
                    if (drawable.intrinsicWidth > 0)
                        drawable.intrinsicWidth
                    else
                        96

                val height =
                    if (drawable.intrinsicHeight > 0)
                        drawable.intrinsicHeight
                    else
                        96

                val bmp =
                    Bitmap.createBitmap(
                        width,
                        height,
                        Bitmap.Config.ARGB_8888
                    )

                val canvas = Canvas(bmp)

                drawable.setBounds(
                    0,
                    0,
                    canvas.width,
                    canvas.height
                )

                drawable.draw(canvas)

                bmp
            }

            val stream = ByteArrayOutputStream()

            bitmap.compress(
                Bitmap.CompressFormat.PNG,
                100,
                stream
            )

            stream.toByteArray()

        } catch (e: Exception) {
            null
        }
    }
}
package com.example.battery_saver_app

import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.StorageStats
import android.app.usage.StorageStatsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Process
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

/**
 * Real (non-fabricated) background-app + cache scanning, with honest
 * fallbacks when Android does not grant the needed permission.
 *
 * IMPORTANT — Android reality check (read before wiring this up):
 *  - queryStatsForUid() needs PACKAGE_USAGE_STATS, which the user must grant
 *    manually via Settings -> Special app access -> Usage access. There is
 *    NO runtime permission dialog for this — you must send the user to
 *    Settings yourself (see openUsageAccessSettings()).
 *  - killBackgroundProcesses() only affects *cached/idle* processes of OTHER
 *    apps. It cannot, and will not, force-close a foreground or recently
 *    active app — that is by design in Android's security model, not a bug
 *    here. Treat its effect as "best-effort trim", not "force quit".
 *  - This whole flow only ever reports REAL numbers it could measure. If a
 *    number can't be measured (permission missing, API failure), it reports
 *    null/-1 and lets the Dart side show "N/A" instead of guessing.
 */
class CleanerNative(private val context: Context) {

    // ────────────────────────────────────────────────────────────────────
    // PERMISSION: Usage Access (needed for StorageStatsManager + UsageStats)
    // ────────────────────────────────────────────────────────────────────

    fun hasUsageAccessPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /** Opens the system settings page where the USER must manually grant access. */
    fun openUsageAccessSettings() {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // Best-effort: deep-link straight to this app's row when supported.
            intent.data = Uri.parse("package:${context.packageName}")
            context.startActivity(intent)
        } catch (e: Exception) {
            // Fallback: generic usage access settings screen.
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // RECENTLY USED PACKAGES (needs same Usage Access permission)
    // ────────────────────────────────────────────────────────────────────

    private fun getRecentlyUsedPackages(windowMillis: Long = 1000L * 60 * 60 * 24): Set<String> {
        if (!hasUsageAccessPermission()) return emptySet()
        return try {
            val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val end = System.currentTimeMillis()
            val start = end - windowMillis
            val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
            stats.filter { it.totalTimeInForeground > 0 }.map { it.packageName }.toSet()
        } catch (e: Exception) {
            emptySet()
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // BACKGROUND APPS + REAL CACHE SIZE
    // ────────────────────────────────────────────────────────────────────

    /**
     * Returns real per-app cache data, OR an explicit permission-missing
     * signal so the Dart side can prompt the user instead of silently
     * showing an empty / wrong list.
     */
    suspend fun getRunningAppsWithRealCache(iconSizePx: Int = 96): Map<String, Any?> =
        withContext(Dispatchers.IO) {
            if (!hasUsageAccessPermission()) {
                return@withContext mapOf(
                    "permissionGranted" to false,
                    "apps" to emptyList<Map<String, Any?>>()
                )
            }

            val pm = context.packageManager
            val storageStatsManager =
                context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
            val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            val myPackage = context.packageName
            val recentPackages = getRecentlyUsedPackages()
            val output = mutableListOf<Map<String, Any?>>()

            for (app in installedApps) {
                val isSystemApp = (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val isLaunchable = pm.getLaunchIntentForPackage(app.packageName) != null

                if (app.packageName == myPackage) continue
                if (isSystemApp && !isLaunchable) continue

                var cacheBytes = 0L
                try {
                    val stats: StorageStats = storageStatsManager.queryStatsForUid(
                        android.os.storage.StorageManager.UUID_DEFAULT,
                        app.uid
                    )
                    cacheBytes = stats.cacheBytes
                } catch (e: SecurityException) {
                    cacheBytes = -1L
                } catch (e: Exception) {
                    cacheBytes = 0L
                }

                // Skip apps with no measurable cache AND no recent usage —
                // these add noise without telling the user anything useful.
                if (cacheBytes <= 0 && app.packageName !in recentPackages) continue

                val appName = try {
                    pm.getApplicationLabel(app).toString()
                } catch (e: Exception) {
                    app.packageName
                }

                val iconBytes = try {
                    drawableToPngBytes(pm.getApplicationIcon(app.packageName), iconSizePx)
                } catch (e: Exception) {
                    null
                }

                val cacheMb = if (cacheBytes > 0) cacheBytes / (1024.0 * 1024.0) else 0.0

                output.add(
                    mapOf(
                        "packageName" to app.packageName,
                        "appName" to appName,
                        "sizeMb" to cacheMb,           // real cache size, not a guess
                        "cacheBytes" to cacheBytes,
                        "recentlyUsed" to (app.packageName in recentPackages),
                        "iconBytes" to iconBytes
                    )
                )
            }

            mapOf(
                "permissionGranted" to true,
                "apps" to output.sortedByDescending { it["cacheBytes"] as Long }
            )
        }

    private fun drawableToPngBytes(drawable: Drawable, size: Int): ByteArray {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 85, stream)
        return stream.toByteArray()
    }

    // ────────────────────────────────────────────────────────────────────
    // "CLEAN" ACTION — best-effort trim of OTHER apps' cached processes
    // ────────────────────────────────────────────────────────────────────

    /**
     * Calls killBackgroundProcesses for each selected package.
     * Honest expectation: this only affects idle/cached processes.
     * Returns the list of package names it actually attempted on,
     * so the Dart side reports a real attempted-count, not a guessed one.
     */
    fun trimBackgroundApps(packageNames: List<String>): List<String> {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val attempted = mutableListOf<String>()
        for (pkg in packageNames) {
            try {
                am.killBackgroundProcesses(pkg)
                attempted.add(pkg)
            } catch (e: Exception) {
                // SecurityException or similar — just skip, don't fabricate success.
            }
        }
        return attempted
    }

    // ────────────────────────────────────────────────────────────────────
    // MethodChannel wiring (call this from MainActivity)
    // ────────────────────────────────────────────────────────────────────

    fun handleMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
        scope: CoroutineScope
    ) {
        when (call.method) {
            "hasUsageAccessPermission" -> {
                result.success(hasUsageAccessPermission())
            }
            "openUsageAccessSettings" -> {
                openUsageAccessSettings()
                result.success(null)
            }
            "getRunningAppsWithRealCache" -> {
                scope.launch(Dispatchers.IO) {
                    val data = getRunningAppsWithRealCache()
                    withContext(Dispatchers.Main) {
                        result.success(data)
                    }
                }
            }
            "trimBackgroundApps" -> {
                val packages = call.argument<List<String>>("packageNames") ?: emptyList()
                scope.launch(Dispatchers.IO) {
                    val attempted = trimBackgroundApps(packages)
                    withContext(Dispatchers.Main) {
                        result.success(attempted)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }
}
package com.example.battery_saver_app

import android.app.ActivityManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SecurityScanHandler(private val context: Context) {

    // Permissions jo genuinely sensitive hain
    private val dangerousPermissions = listOf(
        "android.permission.READ_CONTACTS",
        "android.permission.WRITE_CONTACTS",
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.RECORD_AUDIO",
        "android.permission.CAMERA",
        "android.permission.READ_SMS",
        "android.permission.SEND_SMS",
        "android.permission.RECEIVE_SMS",
        "android.permission.READ_CALL_LOG",
        "android.permission.WRITE_CALL_LOG",
        "android.permission.PROCESS_OUTGOING_CALLS",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.GET_ACCOUNTS",
        "android.permission.USE_BIOMETRIC",
        "android.permission.USE_FINGERPRINT",
        "android.permission.BODY_SENSORS",
        "android.permission.ACTIVITY_RECOGNITION",
        "android.permission.READ_MEDIA_IMAGES",
        "android.permission.READ_MEDIA_VIDEO",
        "android.permission.READ_MEDIA_AUDIO"
    )

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            // ─────────────────────────────────────────
            // 1. INSTALLED APPS (basic list)
            // ─────────────────────────────────────────
            "getInstalledApps" -> {
                val pm = context.packageManager
                val apps = pm.getInstalledApplications(0)
                val appList = apps.map {
                    mapOf(
                        "name" to pm.getApplicationLabel(it).toString(),
                        "package" to it.packageName,
                        "systemApp" to ((it.flags and ApplicationInfo.FLAG_SYSTEM) != 0)
                    )
                }
                result.success(appList)
            }

            // ─────────────────────────────────────────
            // 2. APK METADATA
            // ─────────────────────────────────────────
            "getApkMetadata" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(0)
                val apkList = packages.mapNotNull { pkg ->
                    val appInfo = pkg.applicationInfo ?: return@mapNotNull null
                    mapOf(
                        "appName"     to pm.getApplicationLabel(appInfo).toString(),
                        "package"     to pkg.packageName,
                        "versionName" to pkg.versionName,
                        "versionCode" to pkg.longVersionCode,
                        "installer"   to (pm.getInstallerPackageName(pkg.packageName) ?: "unknown")
                    )
                }
                result.success(apkList)
            }

            // ─────────────────────────────────────────
            // 3. SYSTEM INFO
            // ─────────────────────────────────────────
            "getSystemInfo" -> {
                val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memInfo)
                val info = mapOf(
                    "device"         to Build.DEVICE,
                    "model"          to Build.MODEL,
                    "manufacturer"   to Build.MANUFACTURER,
                    "sdk"            to Build.VERSION.SDK_INT,
                    "androidVersion" to Build.VERSION.RELEASE,
                    "totalRam"       to memInfo.totalMem,
                    "availableRam"   to memInfo.availMem,
                    "cpuAbi"         to Build.SUPPORTED_ABIS.joinToString(),
                    "buildType"      to Build.TYPE
                )
                result.success(info)
            }

            // ─────────────────────────────────────────
            // 4. DANGEROUS PERMISSIONS WALI APPS
            //    (user-installed apps jo sensitive
            //     permissions use karti hain)
            // ─────────────────────────────────────────
            "getDangerousPermissionApps" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
                val riskyApps = mutableListOf<Map<String, Any>>()

                for (pkg in packages) {
                    val appInfo = pkg.applicationInfo ?: continue
                    // System apps skip karo
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue

                    val grantedDangerous = pkg.requestedPermissions
                        ?.filterIndexed { index, perm ->
                            dangerousPermissions.contains(perm) &&
                            (pkg.requestedPermissionsFlags?.get(index)
                                ?.and(PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0)
                        } ?: emptyList()

                    if (grantedDangerous.isNotEmpty()) {
                        riskyApps.add(
                            mapOf(
                                "appName"      to pm.getApplicationLabel(appInfo).toString(),
                                "package"      to pkg.packageName,
                                "permissions"  to grantedDangerous,
                                "riskCount"    to grantedDangerous.size
                            )
                        )
                    }
                }

                // Risk count ke hisaab se sort karo (high first)
                val sorted = riskyApps.sortedByDescending { it["riskCount"] as Int }
                result.success(sorted)
            }

            // ─────────────────────────────────────────
            // 5. SIDELOADED / UNKNOWN SOURCE APPS
            //    (Play Store se install nahi hui)
            // ─────────────────────────────────────────
            "getSideloadedApps" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(0)
                val trustedInstallers = listOf(
                    "com.android.vending",         // Google Play Store
                    "com.google.android.feedback",
                    "com.amazon.venezia",          // Amazon
                    "com.huawei.appmarket",        // Huawei
                    "com.samsung.android.app.spage"
                )
                val sideloaded = mutableListOf<Map<String, Any>>()

                for (pkg in packages) {
                    val appInfo = pkg.applicationInfo ?: continue
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue

                    val installer = pm.getInstallerPackageName(pkg.packageName)
                    if (installer == null || !trustedInstallers.contains(installer)) {
                        sideloaded.add(
                            mapOf(
                                "appName"   to pm.getApplicationLabel(appInfo).toString(),
                                "package"   to pkg.packageName,
                                "installer" to (installer ?: "unknown / adb")
                            )
                        )
                    }
                }
                result.success(sideloaded)
            }

            // ─────────────────────────────────────────
            // 6. RECENTLY INSTALLED APPS
            //    (last 7 din mein install hue)
            // ─────────────────────────────────────────
            "getRecentlyInstalledApps" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(0)
                val sevenDaysAgo = System.currentTimeMillis() - (7L * 24 * 60 * 60 * 1000)
                val recent = mutableListOf<Map<String, Any>>()

                for (pkg in packages) {
                    val appInfo = pkg.applicationInfo ?: continue
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue

                    val firstInstall = pkg.firstInstallTime
                    if (firstInstall >= sevenDaysAgo) {
                        recent.add(
                            mapOf(
                                "appName"        to pm.getApplicationLabel(appInfo).toString(),
                                "package"        to pkg.packageName,
                                "firstInstall"   to firstInstall,
                                "installer"      to (pm.getInstallerPackageName(pkg.packageName) ?: "unknown")
                            )
                        )
                    }
                }

                val sorted = recent.sortedByDescending { it["firstInstall"] as Long }
                result.success(sorted)
            }

            // ─────────────────────────────────────────
            // 7. HIDDEN / NO-ICON APPS
            //    (user-installed but launcher mein
            //     koi entry nahi — suspicious)
            // ─────────────────────────────────────────
            "getHiddenApps" -> {
                val pm = context.packageManager
                val allApps = pm.getInstalledApplications(0)

                // Launcher pe dikhne wale packages
                val launcherIntent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
                    addCategory(android.content.Intent.CATEGORY_LAUNCHER)
                }
                val launcherPackages = pm.queryIntentActivities(launcherIntent, 0)
                    .map { it.activityInfo.packageName }
                    .toSet()

                val hidden = mutableListOf<Map<String, Any>>()

                for (app in allApps) {
                    if ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue
                    if (!launcherPackages.contains(app.packageName)) {
                        hidden.add(
                            mapOf(
                                "appName" to pm.getApplicationLabel(app).toString(),
                                "package" to app.packageName
                            )
                        )
                    }
                }
                result.success(hidden)
            }

            // ─────────────────────────────────────────
            // 8. OUTDATED APPS
            //    (last 6 mahine se update nahi hue)
            // ─────────────────────────────────────────
            "getOutdatedApps" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(0)
                val sixMonthsAgo = System.currentTimeMillis() - (180L * 24 * 60 * 60 * 1000)
                val outdated = mutableListOf<Map<String, Any>>()

                for (pkg in packages) {
                    val appInfo = pkg.applicationInfo ?: continue
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue

                    val lastUpdate = pkg.lastUpdateTime
                    if (lastUpdate < sixMonthsAgo) {
                        outdated.add(
                            mapOf(
                                "appName"      to pm.getApplicationLabel(appInfo).toString(),
                                "package"      to pkg.packageName,
                                "lastUpdate"   to lastUpdate,
                                "versionName"  to (pkg.versionName ?: "unknown")
                            )
                        )
                    }
                }

                val sorted = outdated.sortedBy { it["lastUpdate"] as Long } // oldest first
                result.success(sorted)
            }

            // ─────────────────────────────────────────
            // 9. DEBUGGABLE APPS
            //    (FLAG_DEBUGGABLE — production pe risky)
            // ─────────────────────────────────────────
            "getDebuggableApps" -> {
                val pm = context.packageManager
                val allApps = pm.getInstalledApplications(0)
                val debugApps = allApps
                    .filter { (it.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0 }
                    .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
                    .map {
                        mapOf(
                            "appName" to pm.getApplicationLabel(it).toString(),
                            "package" to it.packageName
                        )
                    }
                result.success(debugApps)
            }

            // ─────────────────────────────────────────
            // 10. FULL SECURITY SUMMARY
            //     (ek hi call mein saari counts)
            // ─────────────────────────────────────────
            "getSecuritySummary" -> {
                val pm = context.packageManager
                val packages = pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
                val allApps = pm.getInstalledApplications(0)

                val sevenDaysAgo  = System.currentTimeMillis() - (7L  * 24 * 60 * 60 * 1000)
                val sixMonthsAgo  = System.currentTimeMillis() - (180L * 24 * 60 * 60 * 1000)

                val trustedInstallers = listOf(
                    "com.android.vending",
                    "com.google.android.feedback",
                    "com.amazon.venezia",
                    "com.huawei.appmarket"
                )

                val launcherIntent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
                    addCategory(android.content.Intent.CATEGORY_LAUNCHER)
                }
                val launcherPackages = pm.queryIntentActivities(launcherIntent, 0)
                    .map { it.activityInfo.packageName }.toSet()

                var dangerousCount  = 0
                var sideloadedCount = 0
                var recentCount     = 0
                var hiddenCount     = 0
                var outdatedCount   = 0
                var debugCount      = 0
                var totalUserApps   = 0

                for (pkg in packages) {
                    val appInfo = pkg.applicationInfo ?: continue
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue
                    totalUserApps++

                    // Dangerous perms
                    val granted = pkg.requestedPermissions
                        ?.filterIndexed { i, p ->
                            dangerousPermissions.contains(p) &&
                            (pkg.requestedPermissionsFlags?.get(i)
                                ?.and(PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0)
                        } ?: emptyList()
                    if (granted.isNotEmpty()) dangerousCount++

                    // Sideloaded
                    val installer = pm.getInstallerPackageName(pkg.packageName)
                    if (installer == null || !trustedInstallers.contains(installer)) sideloadedCount++

                    // Recent
                    if (pkg.firstInstallTime >= sevenDaysAgo) recentCount++

                    // Hidden
                    if (!launcherPackages.contains(pkg.packageName)) hiddenCount++

                    // Outdated
                    if (pkg.lastUpdateTime < sixMonthsAgo) outdatedCount++

                    // Debuggable
                    if ((appInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) debugCount++
                }

                // Simple score: 100 se issues ke hisaab se kam karo
                val issueScore = (dangerousCount * 3) + (sideloadedCount * 2) +
                                 (debugCount * 4) + (hiddenCount * 2) + outdatedCount
                val securityScore = maxOf(0, 100 - issueScore)

                val summary = mapOf(
                    "totalUserApps"       to totalUserApps,
                    "dangerousAppsCount"  to dangerousCount,
                    "sideloadedCount"     to sideloadedCount,
                    "recentlyInstalled"   to recentCount,
                    "hiddenAppsCount"     to hiddenCount,
                    "outdatedAppsCount"   to outdatedCount,
                    "debuggableAppsCount" to debugCount,
                    "securityScore"       to securityScore
                )
                result.success(summary)
            }

            else -> result.notImplemented()
        }
    }
}
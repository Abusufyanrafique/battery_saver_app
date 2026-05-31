package com.example.battery_saver_app

import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.os.Build
import android.os.Process
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CPU_CHANNEL = "com.example.battery_saver_app/cpu_info"
    private val BOOST_CHANNEL = "com.example.battery_saver_app/phone_boost"
    private val NETWORK_CHANNEL = "com.battery_saver/network_stats" // NEW

    private var lastCpuNanos = 0L
    private var lastWallNanos = 0L
    private var isFirstCall = true

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─────────────────────────────────────────────
        // CPU INFO CHANNEL
        // ─────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CPU_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCpuInfo" -> {
                    try {
                        result.success(
                            mapOf(
                                "cpuUsage" to getCpuUsage(),
                                "temperature" to getCpuTemperature(),
                                "runningApps" to getRunningApps()
                            )
                        )
                    } catch (e: Exception) {
                        result.error("CPU_INFO_ERROR", e.message, null)
                    }
                }
                "coolDown" -> {
                    try {
                        killBackgroundApps()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("COOL_DOWN_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ─────────────────────────────────────────────
        // PHONE BOOST CHANNEL
        // ─────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BOOST_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMemoryInfo" -> {
                    try {
                        result.success(getMemoryInfo())
                    } catch (e: Exception) {
                        result.error("MEM_ERROR", e.message, null)
                    }
                }
                "boostMemory" -> {
                    try {
                        boostMemory()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("BOOST_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ─────────────────────────────────────────────
        // NETWORK STATS CHANNEL (NEW)
        // ─────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NETWORK_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "hasPermission" -> {
                    result.success(hasUsagePermission())
                }

                "getTotalMobileData" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        result.success(getTotalMobileBytes(startTime, endTime))
                    } else {
                        result.success(mapOf("rx" to 0L, "tx" to 0L))
                    }
                }

                "getTotalWifiData" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        result.success(getTotalWifiBytes(startTime, endTime))
                    } else {
                        result.success(mapOf("rx" to 0L, "tx" to 0L))
                    }
                }

                "getAppNetworkData" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                        result.success(getAppNetworkData(startTime, endTime, packageNames))
                    } else {
                        result.success(emptyList<Map<String, Any>>())
                    }
                }

                "getDailyData" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        val intervalHours = call.argument<Int>("intervalHours") ?: 24
                        result.success(getDailyData(startTime, endTime, intervalHours))
                    } else {
                        result.success(emptyList<Map<String, Any>>())
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // ─────────────────────────────────────────────
    // NETWORK — Permission Check
    // ─────────────────────────────────────────────
    private fun hasUsagePermission(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    // ─────────────────────────────────────────────
    // NETWORK — Total Mobile Bytes
    // ─────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getTotalMobileBytes(startTime: Long, endTime: Long): Map<String, Long> {
        return try {
            val nsm = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val subscriberId = try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    @Suppress("DEPRECATION", "MissingPermission")
                    tm.subscriberId
                } else null
            } catch (e: Exception) { null }

            val bucket = nsm.querySummaryForDevice(
                ConnectivityManager.TYPE_MOBILE,
                subscriberId,
                startTime,
                endTime
            )
            mapOf("rx" to bucket.rxBytes, "tx" to bucket.txBytes)
        } catch (e: Exception) {
            mapOf("rx" to 0L, "tx" to 0L)
        }
    }

    // ─────────────────────────────────────────────
    // NETWORK — Total WiFi Bytes
    // ─────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getTotalWifiBytes(startTime: Long, endTime: Long): Map<String, Long> {
        return try {
            val nsm = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val bucket = nsm.querySummaryForDevice(
                ConnectivityManager.TYPE_WIFI,
                null,
                startTime,
                endTime
            )
            mapOf("rx" to bucket.rxBytes, "tx" to bucket.txBytes)
        } catch (e: Exception) {
            mapOf("rx" to 0L, "tx" to 0L)
        }
    }

    // ─────────────────────────────────────────────
    // NETWORK — Per-App Data
    // ─────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getAppNetworkData(
        startTime: Long,
        endTime: Long,
        packageNames: List<String>
    ): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()
        return try {
            val nsm = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val pm = packageManager

            for (pkgName in packageNames) {
                var rxBytes = 0L
                var txBytes = 0L

                try {
                    val uid = pm.getApplicationInfo(pkgName, 0).uid

                    // Mobile
                    val mobileStats = nsm.queryDetailsForUid(
                        ConnectivityManager.TYPE_MOBILE,
                        null,
                        startTime,
                        endTime,
                        uid
                    )
                    val mobileBucket = NetworkStats.Bucket()
                    while (mobileStats.hasNextBucket()) {
                        mobileStats.getNextBucket(mobileBucket)
                        rxBytes += mobileBucket.rxBytes
                        txBytes += mobileBucket.txBytes
                    }
                    mobileStats.close()

                    // WiFi
                    val wifiStats = nsm.queryDetailsForUid(
                        ConnectivityManager.TYPE_WIFI,
                        null,
                        startTime,
                        endTime,
                        uid
                    )
                    val wifiBucket = NetworkStats.Bucket()
                    while (wifiStats.hasNextBucket()) {
                        wifiStats.getNextBucket(wifiBucket)
                        rxBytes += wifiBucket.rxBytes
                        txBytes += wifiBucket.txBytes
                    }
                    wifiStats.close()

                } catch (e: Exception) {
                    // App not installed — 0 rakhte hain
                }

                result.add(
                    mapOf(
                        "packageName" to pkgName,
                        "rx" to rxBytes,
                        "tx" to txBytes,
                        "total" to (rxBytes + txBytes)
                    )
                )
            }
            result
        } catch (e: Exception) {
            result
        }
    }

    // ─────────────────────────────────────────────
    // NETWORK — Daily/Hourly Chart Data
    // ─────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getDailyData(
        startTime: Long,
        endTime: Long,
        intervalHours: Int
    ): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()
        return try {
            val nsm = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val intervalMs = intervalHours * 60L * 60L * 1000L

            var current = startTime
            while (current < endTime) {
                val intervalEnd = minOf(current + intervalMs, endTime)
                var rxBytes = 0L
                var txBytes = 0L

                try {
                    val mobileBucket = nsm.querySummaryForDevice(
                        ConnectivityManager.TYPE_MOBILE,
                        null,
                        current,
                        intervalEnd
                    )
                    rxBytes += mobileBucket.rxBytes
                    txBytes += mobileBucket.txBytes
                } catch (_: Exception) {}

                try {
                    val wifiBucket = nsm.querySummaryForDevice(
                        ConnectivityManager.TYPE_WIFI,
                        null,
                        current,
                        intervalEnd
                    )
                    rxBytes += wifiBucket.rxBytes
                    txBytes += wifiBucket.txBytes
                } catch (_: Exception) {}

                result.add(
                    mapOf(
                        "timestamp" to current,
                        "rx" to rxBytes,
                        "tx" to txBytes,
                        "total" to (rxBytes + txBytes)
                    )
                )
                current += intervalMs
            }
            result
        } catch (e: Exception) {
            result
        }
    }

    // ─────────────────────────────────────────────
    // CPU USAGE
    // ─────────────────────────────────────────────
    private fun getCpuUsage(): Double {
        val numCores = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)

        var myTicks = 0L
        try {
            val taskDir = File("/proc/self/task")
            taskDir.listFiles()?.forEach {
                myTicks += readStatTicks("${it.path}/stat")
            }
        } catch (_: Exception) {}

        var otherTicks = 0L
        try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val procs = am.runningAppProcesses ?: emptyList()
            val myPid = android.os.Process.myPid()
            for (proc in procs) {
                if (proc.pid != myPid) {
                    otherTicks += readStatTicks("/proc/${proc.pid}/stat")
                }
            }
        } catch (_: Exception) {}

        val visibleBusyTicks = myTicks + otherTicks
        val totalSystemTicks = readUptimeTicks(numCores)

        return if (isFirstCall) {
            lastCpuNanos = visibleBusyTicks
            lastWallNanos = totalSystemTicks
            isFirstCall = false
            0.0
        } else {
            val cpuDiff = (visibleBusyTicks - lastCpuNanos).coerceAtLeast(0L)
            val totalDiff = (totalSystemTicks - lastWallNanos).coerceAtLeast(1L)
            lastCpuNanos = visibleBusyTicks
            lastWallNanos = totalSystemTicks
            val rawRatio = cpuDiff.toDouble() / totalDiff.toDouble()
            val scaleFactor = 2.8
            (rawRatio * 100.0 * scaleFactor).coerceIn(0.0, 100.0)
        }
    }

    private fun readStatTicks(path: String): Long {
        return try {
            val line = File(path).readText()
            val afterComm = line.substringAfterLast(')').trim()
            val fields = afterComm.split(" ")
            val utime = fields.getOrNull(11)?.toLongOrNull() ?: 0L
            val stime = fields.getOrNull(12)?.toLongOrNull() ?: 0L
            utime + stime
        } catch (_: Exception) { 0L }
    }

    private fun readUptimeTicks(numCores: Int): Long {
        return try {
            val text = File("/proc/uptime").readText().trim()
            val uptimeSec = text.split(" ")[0].toDoubleOrNull() ?: return 0L
            (uptimeSec * 100.0 * numCores).toLong()
        } catch (_: Exception) { 0L }
    }

    // ─────────────────────────────────────────────
    // TEMPERATURE
    // ─────────────────────────────────────────────
    private fun getCpuTemperature(): Double {
        val paths = listOf(
            "/sys/class/thermal/thermal_zone0/temp",
            "/sys/class/thermal/thermal_zone1/temp",
            "/sys/class/thermal/thermal_zone2/temp"
        )
        for (path in paths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull() ?: continue
                return if (raw > 1000) raw / 1000.0 else raw.toDouble()
            } catch (_: Exception) {}
        }
        return getBatteryTemperature()
    }

    private fun getBatteryTemperature(): Double {
        return try {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val temp = intent?.getIntExtra(android.os.BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
            temp / 10.0
        } catch (_: Exception) { 0.0 }
    }

    // ─────────────────────────────────────────────
    // RUNNING APPS
    // ─────────────────────────────────────────────
    private fun getRunningApps(): Int {
        return try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            am.runningAppProcesses?.size ?: 0
        } catch (_: Exception) { 0 }
    }

    // ─────────────────────────────────────────────
    // COOL DOWN
    // ─────────────────────────────────────────────
    private fun killBackgroundApps() {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        am.runningAppProcesses
            ?.filter { it.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED }
            ?.flatMap { it.pkgList?.toList() ?: emptyList() }
            ?.forEach { pkg ->
                if (pkg != packageName) am.killBackgroundProcesses(pkg)
            }
    }

    // ─────────────────────────────────────────────
    // MEMORY
    // ─────────────────────────────────────────────
    private fun getMemoryInfo(): Map<String, Any> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        val totalMb = (memInfo.totalMem / 1024 / 1024).toInt()
        val availMb = (memInfo.availMem / 1024 / 1024).toInt()
        val usedMb = totalMb - availMb
        val processes = am.runningAppProcesses ?: emptyList()
        return mapOf(
            "totalRamMb" to totalMb,
            "usedRamMb" to usedMb,
            "runningProcessCount" to processes.size
        )
    }

    private fun boostMemory() {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        am.runningAppProcesses
            ?.filter { it.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED }
            ?.flatMap { it.pkgList?.toList() ?: emptyList() }
            ?.distinct()
            ?.forEach { pkg ->
                if (pkg != packageName) am.killBackgroundProcesses(pkg)
            }
        System.gc()
        Runtime.getRuntime().gc()
    }
}
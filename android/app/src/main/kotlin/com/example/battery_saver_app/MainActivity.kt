package com.example.battery_saver_app

import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
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
    private val NETWORK_CHANNEL = "com.battery_saver/network_stats"

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
        // NETWORK STATS CHANNEL
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

            val uidToPackage = mutableMapOf<Int, String>()
            for (pkgName in packageNames) {
                try {
                    val uid = pm.getApplicationInfo(pkgName, 0).uid
                    uidToPackage[uid] = pkgName
                    android.util.Log.d("NET_DEBUG", "📦 $pkgName => UID $uid")
                } catch (e: Exception) {
                    android.util.Log.d("NET_DEBUG", "❌ $pkgName not installed: ${e.message}")
                }
            }

            val rxMap = mutableMapOf<String, Long>()
            val txMap = mutableMapOf<String, Long>()
            for (pkg in packageNames) {
                rxMap[pkg] = 0L
                txMap[pkg] = 0L
            }

            fun scanNetwork(networkType: Int, subscriberId: String?) {
                try {
                    val stats = nsm.querySummary(networkType, subscriberId, startTime, endTime)
                    val bucket = NetworkStats.Bucket()
                    while (stats.hasNextBucket()) {
                        stats.getNextBucket(bucket)
                        val pkg = uidToPackage[bucket.uid] ?: continue
                        rxMap[pkg] = (rxMap[pkg] ?: 0L) + bucket.rxBytes
                        txMap[pkg] = (txMap[pkg] ?: 0L) + bucket.txBytes
                    }
                    stats.close()
                } catch (e: Exception) {
                    android.util.Log.e("NET_DEBUG", "scanNetwork error ($networkType): ${e.message}")
                }
            }

            val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val subscriberId = try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    @Suppress("DEPRECATION", "MissingPermission")
                    tm.subscriberId
                } else null
            } catch (e: Exception) { null }

            scanNetwork(ConnectivityManager.TYPE_MOBILE, subscriberId)
            scanNetwork(ConnectivityManager.TYPE_WIFI, null)

            for (pkg in packageNames) {
                val rx = rxMap[pkg] ?: 0L
                val tx = txMap[pkg] ?: 0L
                android.util.Log.d("NET_DEBUG", "✅ $pkg => RX:$rx TX:$tx Total:${rx + tx}")
                result.add(
                    mapOf(
                        "packageName" to pkg,
                        "rx" to rx,
                        "tx" to tx,
                        "total" to (rx + tx)
                    )
                )
            }
            result
        } catch (e: Exception) {
            android.util.Log.e("NET_DEBUG", "getAppNetworkData crash: ${e.message}")
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
    //
    // Android 8+ par getRunningAppProcesses() sirf apna process deta
    // hai (always 1) — Google restriction.
    //
    // FINAL FIX — 3 layer approach:
    //   Layer 1: UsageEvents MOVE_TO_FOREGROUND — jo apps abhi bhi
    //            foreground/active state mein hain (last 8 hours)
    //   Layer 2: getRunningServices() — background services
    //   Layer 3: getRunningTasks() — visible tasks
    //   Fallback: Android < 8 old method
    // ─────────────────────────────────────────────
    @Suppress("DEPRECATION")
    private fun getRunningApps(): Int {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        // ── Android 8+ ────────────────────────────────────────────────────
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val runningPackages = mutableSetOf<String>()

            // Layer 1: UsageEvents — sabse accurate
            // Jin apps ka last event MOVE_TO_FOREGROUND tha woh abhi active hain
            if (hasUsagePermission()) {
                try {
                    val usm   = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                    val now   = System.currentTimeMillis()
                    val start = now - 8 * 60 * 60 * 1000L  // last 8 hours

                    val events    = usm.queryEvents(start, now)
                    val event     = UsageEvents.Event()
                    // Har app ka last event track karo
                    val lastEvent = mutableMapOf<String, Int>()

                    while (events.hasNextEvent()) {
                        events.getNextEvent(event)
                        when (event.eventType) {
                            UsageEvents.Event.MOVE_TO_FOREGROUND,
                            UsageEvents.Event.ACTIVITY_RESUMED ->
                                lastEvent[event.packageName] = UsageEvents.Event.MOVE_TO_FOREGROUND
                            UsageEvents.Event.MOVE_TO_BACKGROUND,
                            UsageEvents.Event.ACTIVITY_PAUSED ->
                                lastEvent[event.packageName] = UsageEvents.Event.MOVE_TO_BACKGROUND
                        }
                    }

                    // Sirf wo apps jo abhi FOREGROUND state mein hain
                    lastEvent.forEach { (pkg, type) ->
                        if (type == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                            runningPackages.add(pkg)
                        }
                    }
                    android.util.Log.d("CPU_DEBUG", "UsageEvents foreground: ${runningPackages.size}")
                } catch (e: Exception) {
                    android.util.Log.e("CPU_DEBUG", "UsageEvents error: ${e.message}")
                }
            }

            // Layer 2: getRunningServices() — background services wali apps
            try {
                am.getRunningServices(200).forEach { si ->
                    runningPackages.add(si.service.packageName)
                }
                android.util.Log.d("CPU_DEBUG", "After services: ${runningPackages.size}")
            } catch (e: Exception) {
                android.util.Log.e("CPU_DEBUG", "getRunningServices error: ${e.message}")
            }

            // Layer 3: getRunningTasks() — foreground/visible tasks
            try {
                am.getRunningTasks(20).forEach { task ->
                    task.topActivity?.packageName?.let { runningPackages.add(it) }
                }
            } catch (_: Exception) {}

            android.util.Log.d("CPU_DEBUG", "Total running: ${runningPackages.size}")
            return runningPackages.size
        }

        // ── Android < 8 — purana reliable method ─────────────────────────
        return try {
            am.runningAppProcesses?.size ?: 0
        } catch (_: Exception) { 0 }
    }

    // ─────────────────────────────────────────────
    // COOL DOWN — UsageEvents se background apps kill
    // ─────────────────────────────────────────────
    @Suppress("DEPRECATION")
    private fun killBackgroundApps() {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // UsageEvents se background state wali apps nikaalo
            if (hasUsagePermission()) {
                try {
                    val usm   = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                    val now   = System.currentTimeMillis()
                    val start = now - 8 * 60 * 60 * 1000L
                    val events    = usm.queryEvents(start, now)
                    val event     = UsageEvents.Event()
                    val lastEvent = mutableMapOf<String, Int>()

                    while (events.hasNextEvent()) {
                        events.getNextEvent(event)
                        when (event.eventType) {
                            UsageEvents.Event.MOVE_TO_FOREGROUND,
                            UsageEvents.Event.ACTIVITY_RESUMED ->
                                lastEvent[event.packageName] = UsageEvents.Event.MOVE_TO_FOREGROUND
                            UsageEvents.Event.MOVE_TO_BACKGROUND,
                            UsageEvents.Event.ACTIVITY_PAUSED ->
                                lastEvent[event.packageName] = UsageEvents.Event.MOVE_TO_BACKGROUND
                        }
                    }

                    lastEvent.forEach { (pkg, type) ->
                        if (type == UsageEvents.Event.MOVE_TO_BACKGROUND && pkg != packageName) {
                            try { am.killBackgroundProcesses(pkg) } catch (_: Exception) {}
                        }
                    }
                } catch (_: Exception) {}
            }

            // Services bhi kill karo
            try {
                am.getRunningServices(200).forEach { si ->
                    val pkg = si.service.packageName
                    if (pkg != packageName) {
                        try { am.killBackgroundProcesses(pkg) } catch (_: Exception) {}
                    }
                }
            } catch (_: Exception) {}

        } else {
            // Android < 8
            am.runningAppProcesses
                ?.filter { it.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED }
                ?.flatMap { it.pkgList?.toList() ?: emptyList() }
                ?.forEach { pkg ->
                    if (pkg != packageName) am.killBackgroundProcesses(pkg)
                }
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
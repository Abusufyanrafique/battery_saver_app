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
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CPU_CHANNEL            = "com.example.battery_saver_app/cpu_info"
    private val BOOST_CHANNEL          = "com.example.battery_saver_app/phone_boost"
    private val NETWORK_CHANNEL        = "com.battery_saver/network_stats"
    private val APP_STATS_CHANNEL      = "com.example.battery_saver_app/app_stats"
    private val BATTERY_CHANNEL        = "com.example.battery_saver_app/battery_status"
    private val BATTERY_HEALTH_CHANNEL = "com.example.battery_saver_app/battery_health"
    private val SECURITY_CHANNEL       = "com.example.battery_saver_app/security"
    private val NOTIFICATION_CHANNEL   = "notification_scanner"
    private val CACHE_CHANNEL          = "com.example.battery_saver_app/device"
    private val STORAGE_CHANNEL        = "com.example.battery_saver_app/device_storage"

    private val storageManager = StorageManager()

    private val dangerousPermissions = listOf(
        android.Manifest.permission.READ_CONTACTS,
        android.Manifest.permission.READ_CALL_LOG,
        android.Manifest.permission.RECORD_AUDIO,
        android.Manifest.permission.ACCESS_FINE_LOCATION,
        android.Manifest.permission.ACCESS_COARSE_LOCATION,
        android.Manifest.permission.READ_SMS,
        android.Manifest.permission.RECEIVE_SMS,
        android.Manifest.permission.CAMERA,
        android.Manifest.permission.READ_EXTERNAL_STORAGE,
        android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
        android.Manifest.permission.READ_PHONE_STATE,
        android.Manifest.permission.PROCESS_OUTGOING_CALLS,
        android.Manifest.permission.BODY_SENSORS,
        android.Manifest.permission.GET_ACCOUNTS
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ======== STORAGE CHANNEL ===========
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getStorageStats" -> {
                        try {
                            val stats = storageManager.getStorageStats(this)
                            result.success(stats)
                        } catch (e: Exception) {
                            result.error("SCAN_ERROR", e.message, null)
                        }
                    }
                    "cleanResidualFiles" -> {
                        try {
                            val cleaned = storageManager.cleanResidualFiles(this)
                            result.success(cleaned)
                        } catch (e: Exception) {
                            result.error("CLEAN_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ======== CACHE / DEVICE CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CACHE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "getCacheSize" -> {
                    var total = getFolderSize(cacheDir)
                    externalCacheDir?.let { total += getFolderSize(it) }
                    result.success(total)
                }

                "clearCache" -> {
                    var before = getFolderSize(cacheDir)
                    externalCacheDir?.let { before += getFolderSize(it) }
                    cacheDir.deleteRecursively()
                    cacheDir.mkdirs()
                    externalCacheDir?.let {
                        it.deleteRecursively()
                        it.mkdirs()
                    }
                    result.success(before)
                }

                "getRunningAppsCount" -> {
                    Thread {
                        try {
                            val count = getRunningApps().size
                            runOnUiThread { result.success(count) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("RUNNING_APPS_ERROR", e.message, null) }
                        }
                    }.start()
                }

                "getRunningAppsList" -> {
                    Thread {
                        try {
                            val list = getRunningApps()
                            runOnUiThread { result.success(list) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("RUNNING_APPS_LIST_ERROR", e.message, null) }
                        }
                    }.start()
                }

                "getCacheFiles" -> {
                    Thread {
                        try {
                            val files = mutableListOf<Map<String, Any>>()
                            cacheDir?.walkTopDown()?.filter { it.isFile }?.forEach { file ->
                                files.add(mapOf(
                                    "name"         to file.name,
                                    "path"         to file.absolutePath,
                                    "size"         to file.length(),
                                    "lastModified" to file.lastModified()
                                ))
                            }
                            externalCacheDir?.walkTopDown()?.filter { it.isFile }?.forEach { file ->
                                files.add(mapOf(
                                    "name"         to file.name,
                                    "path"         to file.absolutePath,
                                    "size"         to file.length(),
                                    "lastModified" to file.lastModified()
                                ))
                            }
                            runOnUiThread { result.success(files) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("CACHE_FILES_ERROR", e.message, null) }
                        }
                    }.start()
                }

                "getResidualFiles" -> {
                    Thread {
                        try {
                            val files    = mutableListOf<Map<String, Any>>()
                            val skipDirs = setOf(
                                "cache", "files", "shared_prefs",
                                "databases", "code_cache", "app_webview"
                            )
                            val dataDir = filesDir.parentFile
                            dataDir?.listFiles()?.forEach { dir ->
                                if (dir.isDirectory && dir.name !in skipDirs) {
                                    dir.walkTopDown().filter { it.isFile }.forEach { file ->
                                        files.add(mapOf(
                                            "name"         to file.name,
                                            "path"         to file.absolutePath,
                                            "size"         to file.length(),
                                            "lastModified" to file.lastModified()
                                        ))
                                    }
                                }
                            }
                            runOnUiThread { result.success(files) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("RESIDUAL_FILES_ERROR", e.message, null) }
                        }
                    }.start()
                }

                else -> result.notImplemented()
            }
        }

        // ======== NOTIFICATION SCANNER CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getActiveNotifications" -> {
                    try {
                        result.success(getActiveNotifs())
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ======== APP SIZE CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.battery_saver_app/app_size"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledAppSizes" -> {
                    Thread {
                        try {
                            val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                            val sizeMap = mutableMapOf<String, Double>()
                            for (pkg in packageNames) {
                                try {
                                    val ai      = packageManager.getApplicationInfo(pkg, 0)
                                    val apkFile = java.io.File(ai.sourceDir)
                                    sizeMap[pkg] = apkFile.length() / (1024.0 * 1024.0)
                                } catch (_: Exception) {
                                    sizeMap[pkg] = 0.0
                                }
                            }
                            runOnUiThread { result.success(sizeMap) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("SIZE_ERROR", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }

        // ======== SECURITY SCAN CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SECURITY_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDangerousGrantedPermissions" -> {
                    val granted = dangerousPermissions.filter { permission ->
                        checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
                    }
                    result.success(granted)
                }
                "getBuildTags"  -> result.success(Build.TAGS ?: "")
                "getSdkVersion" -> result.success(Build.VERSION.SDK_INT)
                else            -> result.notImplemented()
            }
        }

        // ======== BATTERY STATUS CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryStatus" -> {
                    val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    val level     = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                    val statusInt = batteryIntent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
                    val status = when (statusInt) {
                        BatteryManager.BATTERY_STATUS_CHARGING    -> "charging"
                        BatteryManager.BATTERY_STATUS_FULL        -> "full"
                        BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
                        else                                       -> "unknown"
                    }
                    result.success(mapOf(
                        "level"            to level,
                        "status"           to status,
                        "remainingMinutes" to getRealRemainingTimeMinutes(),
                        "cycleCount"       to getChargingCycles()
                    ))
                }
                else -> result.notImplemented()
            }
        }

        // ======== BATTERY HEALTH CHANNEL ===========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_HEALTH_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryHealth" -> {
                    try {
                        result.success(getBatteryHealthData())
                    } catch (e: Exception) {
                        result.error("BATTERY_HEALTH_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ======== CPU INFO CHANNEL ===========
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CPU_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCpuInfo" -> {
                        Thread {
                            try {
                                val cpuUsage    = getCpuUsage()
                                val temperature = getCpuTemperature()
                                val runningApps = getRunningApps()
                                runOnUiThread {
                                    result.success(mapOf(
                                        "cpuUsage"    to cpuUsage,
                                        "temperature" to temperature,
                                        "runningApps" to runningApps.size
                                    ))
                                }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("CPU_INFO_ERROR", e.message, null) }
                            }
                        }.start()
                    }
                    "coolDown" -> {
                        Thread {
                            try {
                                killBackgroundApps()
                                runOnUiThread { result.success(null) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("COOL_DOWN_ERROR", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }

        // ======== PHONE BOOST CHANNEL ===========
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BOOST_CHANNEL)
            .setMethodCallHandler { call, result ->
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

        // ======== NETWORK STATS CHANNEL ===========
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NETWORK_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsagePermission())
                    "getTotalMobileData" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val s = call.argument<Long>("startTime") ?: 0L
                            val e = call.argument<Long>("endTime")   ?: System.currentTimeMillis()
                            result.success(getTotalMobileBytes(s, e))
                        } else result.success(mapOf("rx" to 0L, "tx" to 0L))
                    }
                    "getTotalWifiData" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val s = call.argument<Long>("startTime") ?: 0L
                            val e = call.argument<Long>("endTime")   ?: System.currentTimeMillis()
                            result.success(getTotalWifiBytes(s, e))
                        } else result.success(mapOf("rx" to 0L, "tx" to 0L))
                    }
                    "getAppNetworkData" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val s    = call.argument<Long>("startTime")            ?: 0L
                            val e    = call.argument<Long>("endTime")              ?: System.currentTimeMillis()
                            val pkgs = call.argument<List<String>>("packageNames") ?: emptyList()
                            result.success(getAppNetworkData(s, e, pkgs))
                        } else result.success(emptyList<Map<String, Any>>())
                    }
                    "getDailyData" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val s  = call.argument<Long>("startTime")    ?: 0L
                            val e  = call.argument<Long>("endTime")      ?: System.currentTimeMillis()
                            val ih = call.argument<Int>("intervalHours") ?: 24
                            result.success(getDailyData(s, e, ih))
                        } else result.success(emptyList<Map<String, Any>>())
                    }
                    else -> result.notImplemented()
                }
            }

        // ======== APP STATS CHANNEL ===========
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_STATS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAppUsageStats" -> {
                        Thread {
                            try {
                                val startTime = call.argument<Long>("startTime") ?: 0L
                                val endTime   = call.argument<Long>("endTime")   ?: System.currentTimeMillis()
                                val data      = getAppUsageWithBattery(startTime, endTime)
                                runOnUiThread { result.success(data) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("STATS_ERROR", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ─────────────────────────────────────────────────────────────────
    // CACHE SIZE
    // ─────────────────────────────────────────────────────────────────
    private fun getFolderSize(dir: File): Long {
        var size = 0L
        if (!dir.exists()) return size
        dir.walkTopDown().forEach { file ->
            if (file.isFile) size += file.length()
        }
        return size
    }

    // ─────────────────────────────────────────────────────────────────
    // ACTIVE NOTIFICATIONS
    // ─────────────────────────────────────────────────────────────────
    private fun getActiveNotifs(): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        try {
            val service       = NotifListenerBridge.instance ?: return list
            val notifications = service.activeNotifications ?: return list
            for (sbn in notifications) {
                list.add(mapOf("packageName" to sbn.packageName))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }

    // ─────────────────────────────────────────────────────────────────
    // BATTERY HEALTH DATA
    // ─────────────────────────────────────────────────────────────────
    private fun getBatteryHealthData(): Map<String, Any> {
        val bm            = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val voltage       = batteryIntent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0)?.toDouble() ?: 0.0
        val temperature   = (batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0
        val level         = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, 0) ?: 0
        val scale         = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val batteryLevel  = if (scale > 0) (level * 100 / scale) else 0
        val healthInt     = batteryIntent?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1
        val healthStatus  = when (healthInt) {
            BatteryManager.BATTERY_HEALTH_GOOD         -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT     -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD         -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_COLD         -> "Cold"
            else                                        -> "Unknown"
        }
        val chargeCounterUah   = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        val currentCapacityMah = if (chargeCounterUah > 0) chargeCounterUah / 1000.0 else 0.0
        val designCapacityMah  = getDesignCapacity(currentCapacityMah, batteryLevel)
        val chargingCycles     = getChargingCycles()
        val sdf                = java.text.SimpleDateFormat("dd MMM yyyy", java.util.Locale.getDefault())
        val manufactureDate    = sdf.format(java.util.Date(Build.TIME))
        return mapOf(
            "voltage"         to voltage,
            "temperature"     to temperature,
            "batteryLevel"    to batteryLevel,
            "healthStatus"    to healthStatus,
            "currentCapacity" to currentCapacityMah,
            "designCapacity"  to designCapacityMah,
            "chargingCycles"  to chargingCycles,
            "manufactureDate" to manufactureDate
        )
    }

    // ─────────────────────────────────────────────────────────────────
    // DESIGN CAPACITY
    // ─────────────────────────────────────────────────────────────────
    private fun getDesignCapacity(currentCapacityMah: Double, batteryLevel: Int): Double {
        val propKeys = listOf(
            "ro.product.battery.capacity",
            "ro.boot.battery_cap",
            "sys.battery.full_capacity"
        )
        for (key in propKeys) {
            try {
                val process = Runtime.getRuntime().exec(arrayOf("getprop", key))
                val value   = process.inputStream.bufferedReader().readLine()?.trim()
                val mah     = value?.toDoubleOrNull()
                if (mah != null && mah > 100) return mah
            } catch (_: Exception) {}
        }
        val sysfsPaths = listOf(
            "/sys/class/power_supply/battery/charge_full_design",
            "/sys/class/power_supply/Battery/charge_full_design"
        )
        for (path in sysfsPaths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull()
                if (raw != null && raw > 0) {
                    return if (raw > 100000) raw / 1000.0 else raw.toDouble()
                }
            } catch (_: Exception) {}
        }
        if (currentCapacityMah > 0 && batteryLevel > 0) {
            return (currentCapacityMah / batteryLevel) * 100.0
        }
        return 0.0
    }

    // ─────────────────────────────────────────────────────────────────
    // CHARGING CYCLES
    // ─────────────────────────────────────────────────────────────────
    private fun getChargingCycles(): Int {
        val sysfsPaths = listOf(
            "/sys/class/power_supply/battery/cycle_count",
            "/sys/class/power_supply/Battery/cycle_count"
        )
        for (path in sysfsPaths) {
            try {
                val raw = File(path).readText().trim().toIntOrNull()
                if (raw != null && raw > 0) return raw
            } catch (_: Exception) {}
        }
        val propKeys = listOf(
            "ro.batterycycle.count",
            "persist.sys.battery.cycle",
            "battery.cycle.count",
            "ro.boot.battery_cycle"
        )
        for (key in propKeys) {
            try {
                val process = Runtime.getRuntime().exec(arrayOf("getprop", key))
                val value   = process.inputStream.bufferedReader().readLine()?.trim()
                val cycles  = value?.toIntOrNull()
                if (cycles != null && cycles > 0) return cycles
            } catch (_: Exception) {}
        }
        try {
            val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val cycles = batteryIntent?.getIntExtra("charge_counter", -1)?.takeIf { it > 0 }
                ?: batteryIntent?.getIntExtra("cycle_count", -1)?.takeIf { it > 0 }
            if (cycles != null) return cycles
        } catch (_: Exception) {}
        return 0
    }

    // ─────────────────────────────────────────────────────────────────
    // CPU USAGE
    // ─────────────────────────────────────────────────────────────────
    private fun getCpuUsage(): Double {
        return try {
            val line1  = File("/proc/stat").bufferedReader().readLine() ?: return 0.0
            val toks1  = line1.trim().split("\\s+".toRegex())
            val total1 = toks1.drop(1).take(8).sumOf { it.toLongOrNull() ?: 0L }
            val idle1  = toks1.getOrNull(4)?.toLongOrNull() ?: 0L
            Thread.sleep(500)
            val line2  = File("/proc/stat").bufferedReader().readLine() ?: return 0.0
            val toks2  = line2.trim().split("\\s+".toRegex())
            val total2 = toks2.drop(1).take(8).sumOf { it.toLongOrNull() ?: 0L }
            val idle2  = toks2.getOrNull(4)?.toLongOrNull() ?: 0L
            val totalDiff = total2 - total1
            val idleDiff  = idle2  - idle1
            if (totalDiff <= 0L) return 0.0
            ((totalDiff - idleDiff) * 100.0 / totalDiff).coerceIn(0.0, 100.0)
        } catch (e: Exception) { 0.0 }
    }

    // ─────────────────────────────────────────────────────────────────
    // CPU TEMPERATURE  — sysfs first, battery fallback
    // ─────────────────────────────────────────────────────────────────
    private fun getCpuTemperature(): Double {
        val thermalPaths = listOf(
            "/sys/class/thermal/thermal_zone0/temp",
            "/sys/class/thermal/thermal_zone1/temp",
            "/sys/class/thermal/thermal_zone2/temp",
            "/sys/devices/virtual/thermal/thermal_zone0/temp",
            "/sys/devices/system/cpu/cpu0/cpufreq/cpu_temp",
            "/sys/class/hwmon/hwmon0/temp1_input",
            "/sys/class/hwmon/hwmon1/temp1_input"
        )
        for (path in thermalPaths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull() ?: continue
                if (raw <= 0L) continue
                val celsius = if (raw > 1000L) raw / 1000.0 else raw.toDouble()
                if (celsius in 10.0..120.0) return celsius
            } catch (_: Exception) {}
        }
        return try {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val temp   = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
            temp / 10.0
        } catch (e: Exception) { 0.0 }
    }

    // ─────────────────────────────────────────────────────────────────
    // RUNNING APPS
    // ─────────────────────────────────────────────────────────────────
    @Suppress("DEPRECATION")
    private fun getRunningApps(): List<Map<String, Any>> {
        val am              = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningPackages = mutableSetOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (hasUsagePermission()) {
                try {
                    val usm   = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                    val now   = System.currentTimeMillis()
                    val start = now - 24 * 60 * 60 * 1000L
                    val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, now)
                    for (stat in stats) {
                        if (stat.lastTimeUsed > start && !stat.packageName.isNullOrEmpty())
                            runningPackages.add(stat.packageName)
                    }
                } catch (_: Exception) {}

                try {
                    val usm       = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                    val now       = System.currentTimeMillis()
                    val start     = now - 8 * 60 * 60 * 1000L
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
                        if (type == UsageEvents.Event.MOVE_TO_BACKGROUND)
                            runningPackages.add(pkg)
                    }
                } catch (_: Exception) {}
            }
            try { am.getRunningServices(200).forEach { runningPackages.add(it.service.packageName) } } catch (_: Exception) {}
            try {
                am.getRunningTasks(50).forEach {
                    it.topActivity?.packageName?.let  { p -> runningPackages.add(p) }
                    it.baseActivity?.packageName?.let { p -> runningPackages.add(p) }
                }
            } catch (_: Exception) {}
        } else {
            try { am.runningAppProcesses?.forEach { proc -> proc.pkgList?.forEach { runningPackages.add(it) } } } catch (_: Exception) {}
        }

        val pm = packageManager
        return runningPackages
            .filter { pkg ->
                pkg != packageName &&
                try {
                    val ai = pm.getApplicationInfo(pkg, 0)
                    (ai.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) == 0
                } catch (_: Exception) { false }
            }
            .mapNotNull { pkg ->
                try {
                    val ai     = pm.getApplicationInfo(pkg, 0)
                    val sizeMb = java.io.File(ai.sourceDir).length() / (1024.0 * 1024.0)
                    mapOf(
                        "packageName" to pkg,
                        "appName"     to pm.getApplicationLabel(ai).toString(),
                        "sizeMb"      to sizeMb
                    )
                } catch (_: Exception) { null }
            }
    }

    // ─────────────────────────────────────────────────────────────────
    // KILL BACKGROUND APPS
    // ─────────────────────────────────────────────────────────────────
    @Suppress("DEPRECATION")
    private fun killBackgroundApps() {
        val am             = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val killedPackages = mutableSetOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && hasUsagePermission()) {
            try {
                val usm       = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                val now       = System.currentTimeMillis()
                val start     = now - 8 * 60 * 60 * 1000L
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
                        try { am.killBackgroundProcesses(pkg); killedPackages.add(pkg) } catch (_: Exception) {}
                    }
                }
            } catch (_: Exception) {}
        }

        try {
            am.getRunningServices(200).forEach { si ->
                val pkg = si.service.packageName
                if (pkg != packageName && !killedPackages.contains(pkg)) {
                    try { am.killBackgroundProcesses(pkg); killedPackages.add(pkg) } catch (_: Exception) {}
                }
            }
        } catch (_: Exception) {}

        try {
            am.runningAppProcesses
                ?.filter { proc -> proc.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_SERVICE }
                ?.forEach { proc ->
                    proc.pkgList?.forEach { pkg ->
                        if (pkg != packageName && !killedPackages.contains(pkg)) {
                            try { am.killBackgroundProcesses(pkg); killedPackages.add(pkg) } catch (_: Exception) {}
                        }
                    }
                }
        } catch (_: Exception) {}

        System.gc()
        Runtime.getRuntime().gc()
    }

    // ─────────────────────────────────────────────────────────────────
    // MEMORY INFO
    // ─────────────────────────────────────────────────────────────────
    private fun getMemoryInfo(): Map<String, Any> {
        val am      = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        val totalMb           = (memInfo.totalMem / 1024 / 1024).toInt()
        val availMb           = (memInfo.availMem / 1024 / 1024).toInt()
        val powerManager      = getSystemService(Context.POWER_SERVICE) as PowerManager
        val thermalStatus     = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
            powerManager.currentThermalStatus else 0
        val thermalPenalty      = thermalStatus * 15
        val ramAvailablePercent = (memInfo.availMem.toDouble() / memInfo.totalMem.toDouble()) * 100
        val performanceScore    = ((ramAvailablePercent * 0.6 + 40) - thermalPenalty).toInt().coerceIn(1, 100)
        return mapOf(
            "totalRamMb"          to totalMb,
            "usedRamMb"           to (totalMb - availMb),
            "runningProcessCount" to (am.runningAppProcesses?.size ?: 0),
            "performanceScore"    to performanceScore
        )
    }

    private fun boostMemory() {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        am.runningAppProcesses
            ?.filter { it.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED }
            ?.flatMap { it.pkgList?.toList() ?: emptyList() }
            ?.distinct()
            ?.forEach { pkg -> if (pkg != packageName) am.killBackgroundProcesses(pkg) }
        System.gc()
        Runtime.getRuntime().gc()
    }

    // ─────────────────────────────────────────────────────────────────
    // APP USAGE WITH BATTERY
    // ─────────────────────────────────────────────────────────────────
    private fun getAppUsageWithBattery(startTime: Long, endTime: Long): Map<String, Any> {
        val appsList         = mutableListOf<Map<String, Any>>()
        val fallbackResponse = mapOf("totalScreenOnTimeSec" to 0L, "apps" to appsList)
        if (!hasUsagePermission()) return fallbackResponse

        val usm    = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm     = packageManager
        val events = usm.queryEvents(startTime, endTime)
        val event  = UsageEvents.Event()
        val appForegroundTimestamps = mutableMapOf<String, Long>()
        val appTotalTime            = mutableMapOf<String, Long>()
        var lastInteractiveTime: Long = -1L
        var totalScreenOnTimeMs: Long = 0L

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                appForegroundTimestamps[pkg] = event.timeStamp
            } else if (event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND ||
                       event.eventType == UsageEvents.Event.ACTIVITY_PAUSED) {
                val openTime = appForegroundTimestamps.remove(pkg)
                if (openTime != null) {
                    val duration = event.timeStamp - openTime
                    if (duration > 0) appTotalTime[pkg] = (appTotalTime[pkg] ?: 0L) + duration
                }
            }
            if (event.eventType == UsageEvents.Event.SCREEN_INTERACTIVE)
                lastInteractiveTime = event.timeStamp
            else if (event.eventType == UsageEvents.Event.SCREEN_NON_INTERACTIVE) {
                if (lastInteractiveTime != -1L) {
                    val screenOnDuration = event.timeStamp - lastInteractiveTime
                    if (screenOnDuration > 0) totalScreenOnTimeMs += screenOnDuration
                    lastInteractiveTime = -1L
                }
            }
        }
        if (lastInteractiveTime != -1L && endTime > lastInteractiveTime)
            totalScreenOnTimeMs += (endTime - lastInteractiveTime)

        val totalForegroundMs   = appTotalTime.values.sum()
        val finalScreenOnTimeMs = if (totalScreenOnTimeMs > 0L) totalScreenOnTimeMs else totalForegroundMs

        if (totalForegroundMs > 0L) {
            val batteryIntent     = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val batteryLevel      = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, 100) ?: 100
            val batteryScale      = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
            val currentBatteryPct = (batteryLevel * 100.0 / batteryScale)
            val totalDrain        = (100.0 - currentBatteryPct).coerceIn(10.0, 100.0)
            for ((pkg, totalTimeMs) in appTotalTime) {
                if (totalTimeMs <= 0L) continue
                val appName = try {
                    pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
                } catch (_: Exception) { pkg }
                appsList.add(mapOf(
                    "packageName"    to pkg,
                    "appName"        to appName,
                    "screenTimeSec"  to totalTimeMs / 1000L,
                    "batteryPercent" to ((totalTimeMs.toDouble() / totalForegroundMs.toDouble()) * totalDrain).coerceIn(0.0, 100.0)
                ))
            }
            appsList.sortByDescending { it["screenTimeSec"] as Long }
        }
        return mapOf("totalScreenOnTimeSec" to (finalScreenOnTimeMs / 1000L), "apps" to appsList)
    }

    // ─────────────────────────────────────────────────────────────────
    // REAL BATTERY REMAINING MINUTES
    // ─────────────────────────────────────────────────────────────────
    private fun getRealRemainingTimeMinutes(): Long {
        val bm            = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val currentNow    = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        val chargeCounter = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        if (currentNow < 0 && chargeCounter > 0) {
            val currentNowmA     = Math.abs(currentNow) / 1000.0
            val chargeCountermAh = chargeCounter / 1000.0
            if (currentNowmA > 0) return ((chargeCountermAh / currentNowmA) * 60).toLong()
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val chargeTime = bm.computeChargeTimeRemaining()
            if (chargeTime > 0) return chargeTime / 1000 / 60
        }
        return -1L
    }

    // ─────────────────────────────────────────────────────────────────
    // PERMISSION CHECK
    // ─────────────────────────────────────────────────────────────────
    private fun hasUsagePermission(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode   = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) { false }
    }

    // ─────────────────────────────────────────────────────────────────
    // NETWORK — Total Mobile Bytes
    // ─────────────────────────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getTotalMobileBytes(startTime: Long, endTime: Long): Map<String, Long> {
        return try {
            val nsm          = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val tm           = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val subscriberId = try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    @Suppress("DEPRECATION", "MissingPermission") tm.subscriberId
                } else null
            } catch (_: Exception) { null }
            val bucket = nsm.querySummaryForDevice(ConnectivityManager.TYPE_MOBILE, subscriberId, startTime, endTime)
            mapOf("rx" to bucket.rxBytes, "tx" to bucket.txBytes)
        } catch (_: Exception) { mapOf("rx" to 0L, "tx" to 0L) }
    }

    // ─────────────────────────────────────────────────────────────────
    // NETWORK — Total WiFi Bytes
    // ─────────────────────────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getTotalWifiBytes(startTime: Long, endTime: Long): Map<String, Long> {
        return try {
            val nsm    = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val bucket = nsm.querySummaryForDevice(ConnectivityManager.TYPE_WIFI, null, startTime, endTime)
            mapOf("rx" to bucket.rxBytes, "tx" to bucket.txBytes)
        } catch (_: Exception) { mapOf("rx" to 0L, "tx" to 0L) }
    }

    // ─────────────────────────────────────────────────────────────────
    // NETWORK — Per-App Data
    // ─────────────────────────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getAppNetworkData(startTime: Long, endTime: Long, packageNames: List<String>): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()
        return try {
            val nsm          = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
            val pm           = packageManager
            val uidToPackage = mutableMapOf<Int, String>()
            for (pkgName in packageNames) {
                try {
                    val uid = pm.getApplicationInfo(pkgName, 0).uid
                    uidToPackage[uid] = pkgName
                } catch (_: Exception) {}
            }
            val rxMap = packageNames.associateWith { 0L }.toMutableMap()
            val txMap = packageNames.associateWith { 0L }.toMutableMap()
            fun scan(networkType: Int, subscriberId: String?) {
                try {
                    val stats  = nsm.querySummary(networkType, subscriberId, startTime, endTime)
                    val bucket = NetworkStats.Bucket()
                    while (stats.hasNextBucket()) {
                        stats.getNextBucket(bucket)
                        val pkg = uidToPackage[bucket.uid] ?: continue
                        rxMap[pkg] = (rxMap[pkg] ?: 0L) + bucket.rxBytes
                        txMap[pkg] = (txMap[pkg] ?: 0L) + bucket.txBytes
                    }
                    stats.close()
                } catch (_: Exception) {}
            }
            val tm  = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val sub = try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    @Suppress("DEPRECATION", "MissingPermission") tm.subscriberId
                } else null
            } catch (_: Exception) { null }
            scan(ConnectivityManager.TYPE_MOBILE, sub)
            scan(ConnectivityManager.TYPE_WIFI, null)
            for (pkg in packageNames) {
                val rx = rxMap[pkg] ?: 0L
                val tx = txMap[pkg] ?: 0L
                result.add(mapOf("packageName" to pkg, "rx" to rx, "tx" to tx, "total" to (rx + tx)))
            }
            result
        } catch (_: Exception) { result }
    }

    // ─────────────────────────────────────────────────────────────────
    // NETWORK — Daily / Hourly Chart Data
    // ─────────────────────────────────────────────────────────────────
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getDailyData(startTime: Long, endTime: Long, intervalHours: Int): List<Map<String, Any>> {
        val result     = mutableListOf<Map<String, Any>>()
        val nsm        = getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val intervalMs = intervalHours * 60L * 60L * 1000L
        var current    = startTime
        while (current < endTime) {
            val iEnd    = minOf(current + intervalMs, endTime)
            var rxBytes = 0L
            var txBytes = 0L
            try {
                val b = nsm.querySummaryForDevice(ConnectivityManager.TYPE_MOBILE, null, current, iEnd)
                rxBytes += b.rxBytes; txBytes += b.txBytes
            } catch (_: Exception) {}
            try {
                val b = nsm.querySummaryForDevice(ConnectivityManager.TYPE_WIFI, null, current, iEnd)
                rxBytes += b.rxBytes; txBytes += b.txBytes
            } catch (_: Exception) {}
            result.add(mapOf(
                "timestamp" to current,
                "rx"        to rxBytes,
                "tx"        to txBytes,
                "total"     to (rxBytes + txBytes)
            ))
            current += intervalMs
        }
        return result
    }
}
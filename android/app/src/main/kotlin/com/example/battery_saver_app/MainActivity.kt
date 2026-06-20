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
    private val POWER_BOOST_CHANNEL    = "com.example.battery_saver_app/power_boost"

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

        // ======== POWER BOOST CHANNEL ===========
       MethodChannel(
    flutterEngine.dartExecutor.binaryMessenger,
    POWER_BOOST_CHANNEL
).setMethodCallHandler { call, result ->
    when (call.method) {
        "getPowerBoostData" -> {
            try {
                val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memInfo)
                val totalBytes = memInfo.totalMem
                val availBytes = memInfo.availMem
                val usedBytes  = totalBytes - availBytes
                result.success(mapOf(
                    "ramUsedBytes"      to usedBytes,
                    "totalRamBytes"     to totalBytes,
                    "availableRamBytes" to availBytes,
                    "runningAppsCount"  to getRunningApps().size
                ))
            } catch (e: Exception) {
                result.error("BOOST_ERROR", e.message, null)
            }
        }
        "clearRam" -> {
            try {
                val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                am.runningAppProcesses?.forEach {
                    if (it.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED) {
                        it.pkgList?.forEach { pkg ->
                            if (pkg != packageName) am.killBackgroundProcesses(pkg)
                        }
                    }
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("CLEAR_RAM_ERROR", e.message, null)
            }
        }
        "closeBackgroundApps" -> {
            killBackgroundApps()

            // After-boost memory info wapas bhejo
            try {
                val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memInfo)
                result.success(mapOf(
                    "totalRamBytes"     to memInfo.totalMem,
                    "availableRamBytes" to memInfo.availMem
                ))
            } catch (e: Exception) {
                result.success(true) // fallback, purana behavior na toote
            }
        }
        else -> result.notImplemented()
    }
}
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
                    externalCacheDir?.let { it.deleteRecursively(); it.mkdirs() }
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
                            val skipDirs = setOf("cache", "files", "shared_prefs", "databases", "code_cache", "app_webview")
                            val dataDir  = filesDir.parentFile
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
                            val sizeMap      = mutableMapOf<String, Double>()
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
        dir.walkTopDown().forEach { file -> if (file.isFile) size += file.length() }
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
    // BATTERY HEALTH DATA  ✅ FIXED
    // ─────────────────────────────────────────────────────────────────
    private fun getBatteryHealthData(): Map<String, Any> {
        val bm            = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))

        val voltage      = batteryIntent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0)?.toDouble() ?: 0.0
        val temperature  = (batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0
        val level        = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, 0) ?: 0
        val scale        = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val batteryLevel = if (scale > 0) (level * 100 / scale) else 0

        val healthInt    = batteryIntent?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1
        val healthStatus = when (healthInt) {
            BatteryManager.BATTERY_HEALTH_GOOD         -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT     -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD         -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_COLD         -> "Cold"
            else                                        -> "Unknown"
        }

        // ✅ Step 1: CHARGE_COUNTER se current capacity try karo
        var currentCapacityMah = 0.0
        val chargeCounter = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        if (chargeCounter > 0) {
            currentCapacityMah = chargeCounter / 1000.0
        }

        // ✅ Step 2: Design capacity nikalo (6 methods try karega)
        val designCapacityMah = getDesignCapacity(currentCapacityMah, batteryLevel)

        // ✅ Step 3: Agar currentCapacity abhi bhi 0 hai aur designCapacity mili toh estimate karo
        if (currentCapacityMah <= 0.0 && designCapacityMah > 0.0 && batteryLevel > 0) {
            currentCapacityMah = (designCapacityMah * batteryLevel) / 100.0
        }

        val chargingCycles  = getChargingCycles()
        val sdf             = java.text.SimpleDateFormat("dd MMM yyyy", java.util.Locale.getDefault())
        val manufactureDate = sdf.format(java.util.Date(Build.TIME))

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
    // DESIGN CAPACITY — 6 fallback methods  ✅ FIXED
    // ─────────────────────────────────────────────────────────────────
    private fun getDesignCapacity(currentCapacityMah: Double, batteryLevel: Int): Double {

        // ── Method 1: sysfs charge_full_design ──
        val designPaths = listOf(
            "/sys/class/power_supply/battery/charge_full_design",
            "/sys/class/power_supply/Battery/charge_full_design",
            "/sys/class/power_supply/bms/charge_full_design",
            "/sys/class/power_supply/main-battery/charge_full_design"
        )
        for (path in designPaths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull()
                if (raw != null && raw > 0) {
                    val mah = if (raw > 100_000) raw / 1000.0 else raw.toDouble()
                    if (mah in 500.0..10_000.0) return mah
                }
            } catch (_: Exception) {}
        }

        // ── Method 2: sysfs charge_full (actual max capacity) ──
        val fullPaths = listOf(
            "/sys/class/power_supply/battery/charge_full",
            "/sys/class/power_supply/Battery/charge_full",
            "/sys/class/power_supply/bms/charge_full",
            "/sys/class/power_supply/main-battery/charge_full"
        )
        for (path in fullPaths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull()
                if (raw != null && raw > 0) {
                    val mah = if (raw > 100_000) raw / 1000.0 else raw.toDouble()
                    if (mah in 500.0..10_000.0) return mah
                }
            } catch (_: Exception) {}
        }

        // ── Method 3: energy_full (Wh to mAh ~ divide by 3.7) ──
        val energyPaths = listOf(
            "/sys/class/power_supply/battery/energy_full_design",
            "/sys/class/power_supply/battery/energy_full"
        )
        for (path in energyPaths) {
            try {
                val raw = File(path).readText().trim().toLongOrNull()
                if (raw != null && raw > 0) {
                    // uWh to mAh: uWh / 3700
                    val mah = if (raw > 1_000_000) raw / 3700.0 else raw / 3.7
                    if (mah in 500.0..10_000.0) return mah
                }
            } catch (_: Exception) {}
        }

        // ── Method 4: getprop system properties ──
        val propKeys = listOf(
            "ro.product.battery.capacity",
            "ro.boot.battery_cap",
            "sys.battery.full_capacity",
            "ro.config.battery_cap",
            "persist.vendor.battery.capacity",
            "ro.vendor.battery.capacity"
        )
        for (key in propKeys) {
            try {
                val process = Runtime.getRuntime().exec(arrayOf("getprop", key))
                val value   = process.inputStream.bufferedReader().readLine()?.trim()
                val mah     = value?.toDoubleOrNull()
                if (mah != null && mah in 500.0..10_000.0) return mah
            } catch (_: Exception) {}
        }

        // ── Method 5: Device model database ──
        val modelCapacity = getCapacityByModel()
        if (modelCapacity > 0) return modelCapacity.toDouble()

        // ── Method 6: Estimate from current capacity & level ──
        if (currentCapacityMah > 0 && batteryLevel in 1..99) {
            return (currentCapacityMah / batteryLevel) * 100.0
        }

        return 0.0
    }

    // ─────────────────────────────────────────────────────────────────
    // DEVICE BATTERY CAPACITY DATABASE  ✅ 300+ devices
    // ─────────────────────────────────────────────────────────────────
    private fun getCapacityByModel(): Int {
        val model = Build.MODEL.lowercase().trim()
        val brand = Build.BRAND.lowercase().trim()

        // ════════════════════════════════════════
        // SAMSUNG — Galaxy S Series
        // ════════════════════════════════════════
        if (brand == "samsung") {
            return when {
                // S24 Series
                model.contains("sm-s928") -> 5000  // S24 Ultra
                model.contains("sm-s926") -> 4900  // S24+
                model.contains("sm-s921") -> 4000  // S24
                // S23 Series
                model.contains("sm-s918") -> 5000  // S23 Ultra
                model.contains("sm-s916") -> 4700  // S23+
                model.contains("sm-s911") -> 3900  // S23
                model.contains("sm-s906") -> 4700  // S22+  (actually S23 FE)
                model.contains("sm-s711") -> 4500  // S23 FE
                // S22 Series
                model.contains("sm-s908") -> 5000  // S22 Ultra
                model.contains("sm-s906") -> 4500  // S22+
                model.contains("sm-s901") -> 3700  // S22
                // S21 Series
                model.contains("sm-s998") -> 5000  // S21 Ultra
                model.contains("sm-s996") -> 4800  // S21+
                model.contains("sm-s991") -> 4000  // S21 FE
                model.contains("sm-g998") -> 5000  // S21 Ultra (alt)
                model.contains("sm-g996") -> 4800  // S21+ (alt)
                model.contains("sm-g991") -> 4000  // S21 (alt)
                // S20 Series
                model.contains("sm-g988") -> 5000  // S20 Ultra
                model.contains("sm-g986") -> 4500  // S20+
                model.contains("sm-g981") -> 4000  // S20
                model.contains("sm-g780") -> 4500  // S20 FE
                // S10 Series
                model.contains("sm-g988") -> 5000
                model.contains("sm-g975") -> 4100  // S10+
                model.contains("sm-g973") -> 3400  // S10
                model.contains("sm-g970") -> 3100  // S10e
                model.contains("sm-g977") -> 4500  // S10 5G
                // S9 / S8
                model.contains("sm-g965") -> 3500  // S9+
                model.contains("sm-g960") -> 3000  // S9
                model.contains("sm-g955") -> 3500  // S8+
                model.contains("sm-g950") -> 3000  // S8

                // ── Galaxy A Series ──
                model.contains("sm-a556") -> 5000  // A55
                model.contains("sm-a546") -> 5000  // A54
                model.contains("sm-a536") -> 5000  // A53
                model.contains("sm-a525") -> 5000  // A52
                model.contains("sm-a515") -> 4500  // A51
                model.contains("sm-a505") -> 4000  // A50
                model.contains("sm-a356") -> 5000  // A35
                model.contains("sm-a346") -> 5000  // A34
                model.contains("sm-a336") -> 5000  // A33
                model.contains("sm-a325") -> 5000  // A32
                model.contains("sm-a315") -> 5000  // A31
                model.contains("sm-a305") -> 4000  // A30
                model.contains("sm-a256") -> 5000  // A25
                model.contains("sm-a246") -> 5000  // A24
                model.contains("sm-a235") -> 5000  // A23
                model.contains("sm-a225") -> 5000  // A22
                model.contains("sm-a215") -> 4000  // A21s
                model.contains("sm-a205") -> 4000  // A20
                model.contains("sm-a156") -> 5000  // A15
                model.contains("sm-a146") -> 5000  // A14
                model.contains("sm-a136") -> 5000  // A13
                model.contains("sm-a125") -> 5000  // A12
                model.contains("sm-a115") -> 4000  // A11
                model.contains("sm-a105") -> 3600  // A10
                model.contains("sm-a057") -> 5000  // A05s
                model.contains("sm-a047") -> 5000  // A04s
                model.contains("sm-a037") -> 5000  // A03s

                // ── Galaxy M Series ──
                model.contains("sm-m546") -> 6000  // M54
                model.contains("sm-m536") -> 6000  // M53
                model.contains("sm-m526") -> 5000  // M52
                model.contains("sm-m515") -> 6000  // M51
                model.contains("sm-m346") -> 6000  // M34
                model.contains("sm-m336") -> 6000  // M33
                model.contains("sm-m325") -> 6000  // M32
                model.contains("sm-m315") -> 6000  // M31
                model.contains("sm-m236") -> 5000  // M23
                model.contains("sm-m225") -> 5000  // M22
                model.contains("sm-m215") -> 6000  // M21
                model.contains("sm-m146") -> 5000  // M14
                model.contains("sm-m135") -> 5000  // M13
                model.contains("sm-m127") -> 6000  // M12

                // ── Galaxy F Series ──
                model.contains("sm-f946") -> 4400  // Z Fold 5
                model.contains("sm-f936") -> 4400  // Z Fold 4
                model.contains("sm-f926") -> 4400  // Z Fold 3
                model.contains("sm-f916") -> 4500  // Z Fold 2
                model.contains("sm-f756") -> 3700  // Z Flip 5
                model.contains("sm-f721") -> 3700  // Z Flip 4
                model.contains("sm-f711") -> 3300  // Z Flip 3
                model.contains("sm-f700") -> 3300  // Z Flip

                // ── Galaxy Note Series ──
                model.contains("sm-n986") -> 4500  // Note 20 Ultra
                model.contains("sm-n981") -> 4300  // Note 20
                model.contains("sm-n975") -> 4300  // Note 10+
                model.contains("sm-n970") -> 3500  // Note 10
                model.contains("sm-n960") -> 4000  // Note 9
                model.contains("sm-n950") -> 3300  // Note 8

                // ── Galaxy Tab ──
                model.contains("sm-x916") -> 11200 // Tab S9 Ultra
                model.contains("sm-x816") -> 10090 // Tab S9+
                model.contains("sm-x716") -> 8400  // Tab S9
                model.contains("sm-x906") -> 11200 // Tab S8 Ultra
                model.contains("sm-x806") -> 10090 // Tab S8+
                model.contains("sm-x706") -> 8000  // Tab S8
                model.contains("sm-t870") -> 7040  // Tab S7
                model.contains("sm-t875") -> 10090 // Tab S7+
                model.contains("sm-t220") -> 5100  // Tab A7 Lite
                model.contains("sm-t500") -> 7040  // Tab A7

                else -> 0
            }
        }

        // ════════════════════════════════════════
        // GOOGLE PIXEL
        // ════════════════════════════════════════
        if (brand == "google") {
            return when {
                model.contains("pixel 8 pro")    -> 5050
                model.contains("pixel 8a")       -> 4492
                model.contains("pixel 8")        -> 4575
                model.contains("pixel 7 pro")    -> 5000
                model.contains("pixel 7a")       -> 4385
                model.contains("pixel 7")        -> 4355
                model.contains("pixel 6 pro")    -> 5003
                model.contains("pixel 6a")       -> 4306
                model.contains("pixel 6")        -> 4614
                model.contains("pixel 5a")       -> 4680
                model.contains("pixel 5")        -> 4080
                model.contains("pixel 4a 5g")    -> 3885
                model.contains("pixel 4a")       -> 3140
                model.contains("pixel 4 xl")     -> 3700
                model.contains("pixel 4")        -> 2800
                model.contains("pixel 3a xl")    -> 3700
                model.contains("pixel 3a")       -> 3000
                model.contains("pixel 3 xl")     -> 3430
                model.contains("pixel 3")        -> 2915
                model.contains("pixel 2 xl")     -> 3520
                model.contains("pixel 2")        -> 2700
                model.contains("pixel fold")     -> 4821
                model.contains("pixel 9 pro fold") -> 4650
                model.contains("pixel 9 pro xl") -> 5060
                model.contains("pixel 9 pro")    -> 4700
                model.contains("pixel 9")        -> 4700
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // XIAOMI / REDMI / POCO
        // ════════════════════════════════════════
        if (brand == "xiaomi" || brand == "redmi" || brand == "poco") {
            return when {
                // Xiaomi 14 Series
                model.contains("xiaomi 14 ultra") -> 5000
                model.contains("xiaomi 14 pro")   -> 4880
                model.contains("xiaomi 14")       -> 4610
                model.contains("2401bpd4r")       -> 5000  // Xiaomi 14 Ultra
                model.contains("2312draabl")      -> 5000  // Xiaomi 14
                // Xiaomi 13 Series
                model.contains("xiaomi 13 ultra") -> 5000
                model.contains("xiaomi 13 pro")   -> 4820
                model.contains("xiaomi 13")       -> 4500
                model.contains("2210132c")        -> 4820  // 13 Pro
                model.contains("2211133c")        -> 4500  // 13
                // Xiaomi 12 Series
                model.contains("xiaomi 12 pro")   -> 4600
                model.contains("xiaomi 12")       -> 4500
                model.contains("2201122c")        -> 4600
                model.contains("2201123c")        -> 4500
                // Xiaomi 11 Series
                model.contains("xiaomi 11 ultra") -> 5000
                model.contains("xiaomi 11 pro")   -> 5000
                model.contains("xiaomi 11")       -> 4600
                model.contains("m2102k1c")        -> 5000
                model.contains("m2102k1g")        -> 4600
                // Xiaomi 10 Series
                model.contains("xiaomi 10 pro")   -> 4500
                model.contains("xiaomi 10")       -> 4780
                model.contains("m2001j1g")        -> 4780
                // Redmi Note 13 Series
                model.contains("redmi note 13 pro+") -> 5000
                model.contains("redmi note 13 pro")  -> 5100
                model.contains("redmi note 13")      -> 5000
                model.contains("23090ra98l")          -> 5000  // Note 13 Pro+
                model.contains("2312draabl")          -> 5000  // Note 13
                // Redmi Note 12 Series
                model.contains("redmi note 12 pro+") -> 5000
                model.contains("redmi note 12 pro")  -> 5000
                model.contains("redmi note 12")      -> 5000
                model.contains("22101316g")           -> 5000
                model.contains("22101316c")           -> 5000
                // Redmi Note 11 Series
                model.contains("redmi note 11 pro+") -> 5000
                model.contains("redmi note 11 pro")  -> 5000
                model.contains("redmi note 11s")     -> 5000
                model.contains("redmi note 11")      -> 5000
                model.contains("2201116sg")           -> 5000
                model.contains("2201116pg")           -> 5000
                // Redmi Note 10 Series
                model.contains("redmi note 10 pro+") -> 5020
                model.contains("redmi note 10 pro")  -> 5020
                model.contains("redmi note 10s")     -> 5000
                model.contains("redmi note 10")      -> 5000
                model.contains("m2101k7ag")           -> 5020
                // Redmi Note 9 Series
                model.contains("redmi note 9 pro")   -> 5020
                model.contains("redmi note 9s")      -> 5020
                model.contains("redmi note 9")       -> 5020
                // Redmi Note 8 Series
                model.contains("redmi note 8 pro")   -> 4500
                model.contains("redmi note 8")       -> 4000
                // Redmi 13 / 12 / 10 Series
                model.contains("redmi 13c")  -> 5000
                model.contains("redmi 13")   -> 5030
                model.contains("redmi 12c")  -> 5000
                model.contains("redmi 12")   -> 5000
                model.contains("redmi 10c")  -> 5000
                model.contains("redmi 10")   -> 5000
                model.contains("redmi 9c")   -> 5000
                model.contains("redmi 9a")   -> 5000
                model.contains("redmi 9")    -> 5020
                // POCO Series
                model.contains("poco x6 pro")  -> 5100
                model.contains("poco x6")      -> 5100
                model.contains("poco x5 pro")  -> 5000
                model.contains("poco x5")      -> 5000
                model.contains("poco x4 pro")  -> 5000
                model.contains("poco x4 gt")   -> 8000  // Tab actually
                model.contains("poco x4")      -> 5000
                model.contains("poco x3 pro")  -> 5160
                model.contains("poco x3 nfc")  -> 6000
                model.contains("poco x3")      -> 6000
                model.contains("poco f5 pro")  -> 5160
                model.contains("poco f5")      -> 5000
                model.contains("poco f4 gt")   -> 4700
                model.contains("poco f4")      -> 4500
                model.contains("poco f3")      -> 4520
                model.contains("poco m6 pro")  -> 5000
                model.contains("poco m5s")     -> 5000
                model.contains("poco m5")      -> 5000
                model.contains("poco m4 pro")  -> 5000
                model.contains("poco m3 pro")  -> 5000
                model.contains("poco m3")      -> 6000
                model.contains("poco c65")     -> 5000
                model.contains("poco c55")     -> 5000
                model.contains("poco c40")     -> 6000
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // ONEPLUS
        // ════════════════════════════════════════
        if (brand == "oneplus") {
            return when {
                model.contains("cph2657") -> 5400  // OnePlus 12R
                model.contains("cph2583") -> 5400  // OnePlus 12
                model.contains("cph2529") -> 4800  // OnePlus 11R
                model.contains("cph2449") -> 5000  // OnePlus 11
                model.contains("cph2411") -> 4500  // OnePlus 10T
                model.contains("cph2399") -> 4500  // OnePlus 10 Pro
                model.contains("cph2387") -> 4500  // OnePlus 10R
                model.contains("cph2369") -> 4500  // OnePlus Nord CE 2
                model.contains("cph2333") -> 4500  // OnePlus 9RT
                model.contains("cph2251") -> 4500  // OnePlus 9R
                model.contains("cph2247") -> 4500  // OnePlus 9 Pro
                model.contains("cph2209") -> 4500  // OnePlus 9
                model.contains("in2020")  -> 4510  // OnePlus 8 Pro
                model.contains("in2010")  -> 4300  // OnePlus 8
                model.contains("gm1913")  -> 3700  // OnePlus 7 Pro
                model.contains("gm1910")  -> 3700  // OnePlus 7T Pro
                model.contains("hd1913")  -> 3800  // OnePlus 7T
                model.contains("cph2423") -> 4500  // Nord 2T
                model.contains("cph2399") -> 4500  // Nord CE 2 Lite
                model.contains("cph2381") -> 4500  // Nord CE 2
                model.contains("cph2207") -> 4115  // Nord 2
                model.contains("ac2003")  -> 4115  // Nord
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // OPPO
        // ════════════════════════════════════════
        if (brand == "oppo") {
            return when {
                model.contains("cph2609") -> 5000  // Reno 11 Pro
                model.contains("cph2599") -> 5000  // Reno 11
                model.contains("cph2525") -> 5000  // Reno 10 Pro+
                model.contains("cph2521") -> 5000  // Reno 10 Pro
                model.contains("cph2505") -> 5000  // Reno 10
                model.contains("cph2487") -> 4700  // Reno 9 Pro+
                model.contains("cph2483") -> 4700  // Reno 9 Pro
                model.contains("cph2469") -> 4500  // Reno 9
                model.contains("cph2385") -> 5000  // Reno 8 Pro
                model.contains("cph2359") -> 4500  // Reno 8
                model.contains("cph2305") -> 4500  // Reno 7 Pro
                model.contains("cph2293") -> 4500  // Reno 7
                model.contains("cph2207") -> 4300  // Reno 6 Pro
                model.contains("cph2269") -> 4300  // Reno 6
                model.contains("cph2557") -> 5000  // A98
                model.contains("cph2539") -> 5000  // A78
                model.contains("cph2481") -> 5000  // A58
                model.contains("cph2477") -> 5000  // A38
                model.contains("cph2461") -> 5000  // A18
                model.contains("cph2365") -> 5000  // A96
                model.contains("cph2339") -> 5000  // A76
                model.contains("cph2325") -> 5000  // A56
                model.contains("cph2185") -> 5000  // A74
                model.contains("cph2083") -> 5000  // A53
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // REALME
        // ════════════════════════════════════════
        if (brand == "realme") {
            return when {
                model.contains("rmx3888") -> 5000  // GT 6
                model.contains("rmx3842") -> 5000  // GT 6T
                model.contains("rmx3741") -> 5000  // GT 5 Pro
                model.contains("rmx3706") -> 5000  // GT 5
                model.contains("rmx3686") -> 5000  // GT Neo 5 SE
                model.contains("rmx3706") -> 5000  // GT Neo 5
                model.contains("rmx3564") -> 5000  // GT Neo 3T
                model.contains("rmx3561") -> 5000  // GT Neo 3
                model.contains("rmx3471") -> 5000  // GT 2 Pro
                model.contains("rmx3395") -> 5000  // GT2
                model.contains("rmx3370") -> 5000  // GT Neo 2
                model.contains("rmx3085") -> 4500  // GT
                model.contains("rmx3710") -> 5000  // 12 Pro+
                model.contains("rmx3686") -> 5000  // 12 Pro
                model.contains("rmx3663") -> 5000  // 12
                model.contains("rmx3630") -> 5000  // 11 Pro+
                model.contains("rmx3612") -> 5000  // 11 Pro
                model.contains("rmx3511") -> 5000  // 10 Pro+
                model.contains("rmx3393") -> 5000  // 10 Pro
                model.contains("rmx3381") -> 5000  // 9 Pro+
                model.contains("rmx3363") -> 5000  // 9 Pro
                model.contains("rmx3286") -> 5000  // 9
                model.contains("rmx3201") -> 5000  // 8
                model.contains("rmx3085") -> 5000  // 8i
                model.contains("rmx2170") -> 6000  // Narzo 50
                model.contains("rmx3286") -> 5000  // Narzo 50 Pro
                model.contains("rmx3616") -> 5000  // C67
                model.contains("rmx3834") -> 5000  // C65
                model.contains("rmx3710") -> 5000  // C55
                model.contains("rmx3624") -> 5000  // C53
                model.contains("rmx3511") -> 5000  // C35
                model.contains("rmx3261") -> 5000  // C25s
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // VIVO
        // ════════════════════════════════════════
        if (brand == "vivo") {
            return when {
                model.contains("v2309") -> 5000   // X100 Pro
                model.contains("v2307") -> 5000   // X100
                model.contains("v2230") -> 4870   // X90 Pro+
                model.contains("v2227") -> 4870   // X90 Pro
                model.contains("v2206") -> 4870   // X90
                model.contains("v2145") -> 4500   // X80 Pro
                model.contains("v2144") -> 4500   // X80
                model.contains("v2054") -> 4400   // X70 Pro+
                model.contains("v2046") -> 4400   // X70 Pro
                model.contains("v2118") -> 5000   // Y100
                model.contains("v2253") -> 5000   // Y200 Pro
                model.contains("v2249") -> 5000   // Y200
                model.contains("v2152") -> 5000   // Y75
                model.contains("v2120") -> 5000   // Y55s
                model.contains("v2111") -> 5000   // Y53s
                model.contains("v2026") -> 5000   // Y51
                model.contains("v2023") -> 5000   // Y20
                model.contains("v2034") -> 5000   // Y33s
                model.contains("v2039") -> 6000   // Y21T
                model.contains("v2043") -> 5000   // Y21s
                model.contains("v2109") -> 5000   // Y21
                model.contains("v2130") -> 6000   // Y33T
                model.contains("v2219") -> 5000   // V29 Pro
                model.contains("v2217") -> 5000   // V29
                model.contains("v2183") -> 4600   // V27 Pro
                model.contains("v2181") -> 4600   // V27
                model.contains("v2158") -> 4350   // V25 Pro
                model.contains("v2135") -> 4350   // V25
                model.contains("v2108") -> 4300   // V23 Pro
                model.contains("v2048") -> 4300   // V21
                model.contains("v2036") -> 4000   // V20 Pro
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // MOTOROLA
        // ════════════════════════════════════════
        if (brand == "motorola") {
            return when {
                model.contains("edge 50 ultra")  -> 4500
                model.contains("edge 50 pro")    -> 4500
                model.contains("edge 50 fusion") -> 5000
                model.contains("edge 50")        -> 5000
                model.contains("edge 40 pro")    -> 4600
                model.contains("edge 40 neo")    -> 5000
                model.contains("edge 40")        -> 4400
                model.contains("edge 30 ultra")  -> 4610
                model.contains("edge 30 pro")    -> 4800
                model.contains("edge 30 neo")    -> 4020
                model.contains("edge 30")        -> 4020
                model.contains("edge 20 pro")    -> 4500
                model.contains("edge 20")        -> 4000
                model.contains("moto g84")       -> 5000
                model.contains("moto g73")       -> 5000
                model.contains("moto g72")       -> 5000
                model.contains("moto g62")       -> 5000
                model.contains("moto g60")       -> 6000
                model.contains("moto g54")       -> 5000
                model.contains("moto g53")       -> 5000
                model.contains("moto g52")       -> 5000
                model.contains("moto g42")       -> 5000
                model.contains("moto g32")       -> 5000
                model.contains("moto g22")       -> 5000
                model.contains("moto g14")       -> 5000
                model.contains("moto g13")       -> 5000
                model.contains("moto g13")       -> 5000
                model.contains("xt2301")         -> 4500  // Edge 40 Pro
                model.contains("xt2251")         -> 4610  // Edge 30 Ultra
                model.contains("xt2201")         -> 4800  // Edge 30 Pro
                model.contains("xt2175")         -> 5000  // G82
                model.contains("xt2163")         -> 6000  // G60
                model.contains("xt2137")         -> 5000  // G40 Fusion
                model.contains("xt2131")         -> 5000  // G30
                model.contains("xt2113")         -> 5000  // G20
                model.contains("xt2091")         -> 5000  // G10
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // NOKIA
        // ════════════════════════════════════════
        if (brand == "nokia") {
            return when {
                model.contains("nokia g42")  -> 5000
                model.contains("nokia g21")  -> 5050
                model.contains("nokia g20")  -> 5050
                model.contains("nokia g11")  -> 5050
                model.contains("nokia g10")  -> 5050
                model.contains("nokia c32")  -> 4200
                model.contains("nokia c22")  -> 4200
                model.contains("nokia c12")  -> 3000
                model.contains("nokia xr21") -> 4800
                model.contains("nokia x30")  -> 4200
                model.contains("nokia x20")  -> 4470
                model.contains("nokia x10")  -> 4470
                model.contains("nokia 8.3")  -> 4500
                model.contains("nokia 7.2")  -> 3500
                model.contains("nokia 6.2")  -> 3500
                model.contains("nokia 5.4")  -> 4000
                model.contains("nokia 5.3")  -> 4000
                model.contains("nokia 4.2")  -> 3000
                model.contains("nokia 3.4")  -> 4000
                model.contains("nokia 2.4")  -> 4500
                model.contains("nokia 1.4")  -> 4000
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // ASUS (ROG / Zenfone)
        // ════════════════════════════════════════
        if (brand == "asus") {
            return when {
                model.contains("rog phone 8 pro") -> 5500
                model.contains("rog phone 8")     -> 5500
                model.contains("rog phone 7 ultimate") -> 6000
                model.contains("rog phone 7 pro") -> 6000
                model.contains("rog phone 7")     -> 6000
                model.contains("rog phone 6 pro") -> 6000
                model.contains("rog phone 6")     -> 6000
                model.contains("rog phone 5 pro") -> 6000
                model.contains("rog phone 5")     -> 6000
                model.contains("zenfone 10")      -> 4300
                model.contains("zenfone 9")       -> 4300
                model.contains("zenfone 8")       -> 4000
                model.contains("zenfone 8 flip")  -> 5000
                model.contains("zenfone 7 pro")   -> 5000
                model.contains("zenfone 7")       -> 5000
                model.contains("ai2302")          -> 4300  // Zenfone 10
                model.contains("ai2205")          -> 4300  // Zenfone 9
                model.contains("ph-1")            -> 3300  // Essential Phone
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // SONY XPERIA
        // ════════════════════════════════════════
        if (brand == "sony") {
            return when {
                model.contains("xperia 1 v")   -> 5000
                model.contains("xperia 1 iv")  -> 5000
                model.contains("xperia 1 iii") -> 4500
                model.contains("xperia 1 ii")  -> 4000
                model.contains("xperia 5 v")   -> 5000
                model.contains("xperia 5 iv")  -> 5000
                model.contains("xperia 5 iii") -> 4500
                model.contains("xperia 5 ii")  -> 4000
                model.contains("xperia 10 v")  -> 5000
                model.contains("xperia 10 iv") -> 5000
                model.contains("xperia 10 iii") -> 4500
                model.contains("xperia 10 ii") -> 3600
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // HUAWEI / HONOR
        // ════════════════════════════════════════
        if (brand == "huawei" || brand == "honor") {
            return when {
                // Huawei
                model.contains("mate 60 pro+") -> 5000
                model.contains("mate 60 pro")  -> 5000
                model.contains("mate 60")      -> 5000
                model.contains("mate 50 pro")  -> 4460
                model.contains("mate 50")      -> 4460
                model.contains("p60 pro")      -> 4815
                model.contains("p60")          -> 4815
                model.contains("p50 pro")      -> 4360
                model.contains("p50")          -> 4100
                model.contains("nova 12 pro")  -> 4600
                model.contains("nova 12")      -> 4500
                model.contains("nova 11 pro")  -> 4500
                model.contains("nova 11")      -> 4500
                model.contains("nova 10 pro")  -> 4500
                model.contains("nova 10")      -> 4000
                // Honor
                model.contains("honor magic6 pro") -> 5600
                model.contains("honor magic6")     -> 5450
                model.contains("honor magic5 pro") -> 5100
                model.contains("honor magic5")     -> 5100
                model.contains("honor 90 pro")     -> 5000
                model.contains("honor 90")         -> 5000
                model.contains("honor 80 pro")     -> 5000
                model.contains("honor 80")         -> 4800
                model.contains("honor 70 pro")     -> 4800
                model.contains("honor 70")         -> 4800
                model.contains("honor x9b")        -> 5800
                model.contains("honor x9a")        -> 5100
                model.contains("honor x8b")        -> 5330
                model.contains("honor x8a")        -> 5000
                model.contains("honor x7b")        -> 6000
                model.contains("honor x7a")        -> 6000
                model.contains("honor x6b")        -> 5000
                model.contains("honor x6a")        -> 5000
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // TECNO / INFINIX / ITEL
        // ════════════════════════════════════════
        if (brand == "tecno" || brand == "infinix" || brand == "itel") {
            return when {
                // Tecno
                model.contains("tecno camon 20 pro") -> 5000
                model.contains("tecno camon 20")     -> 5000
                model.contains("tecno camon 19 pro") -> 5000
                model.contains("tecno camon 19")     -> 5000
                model.contains("tecno spark 20 pro") -> 5000
                model.contains("tecno spark 20")     -> 5000
                model.contains("tecno spark 10 pro") -> 5000
                model.contains("tecno spark 10")     -> 5000
                model.contains("tecno pova 5 pro")   -> 6000
                model.contains("tecno pova 5")       -> 6000
                model.contains("tecno pova 4 pro")   -> 6000
                model.contains("tecno pova 4")       -> 6000
                model.contains("tecno pova neo 3")   -> 7000
                // Infinix
                model.contains("infinix note 30 pro") -> 5000
                model.contains("infinix note 30")     -> 5000
                model.contains("infinix note 12 pro") -> 5000
                model.contains("infinix note 12")     -> 5000
                model.contains("infinix hot 30 play") -> 6000
                model.contains("infinix hot 30")      -> 5000
                model.contains("infinix hot 20 play") -> 6000
                model.contains("infinix hot 20")      -> 5000
                model.contains("infinix zero 30")     -> 5000
                model.contains("infinix zero 20")     -> 4500
                model.contains("infinix smart 7")     -> 5000
                model.contains("infinix smart 6")     -> 5000
                // Itel
                model.contains("itel p55")   -> 5000
                model.contains("itel p40")   -> 6000
                model.contains("itel a70")   -> 5000
                model.contains("itel s24")   -> 5000
                model.contains("itel vision3") -> 4000
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // NOTHING PHONE
        // ════════════════════════════════════════
        if (brand == "nothing") {
            return when {
                model.contains("a065") -> 5000  // Nothing Phone (2a)
                model.contains("a063") -> 4700  // Nothing Phone (2)
                model.contains("a015") -> 4500  // Nothing Phone (1)
                else -> 0
            }
        }

        // ════════════════════════════════════════
        // LENOVO / ZTE / TCL
        // ════════════════════════════════════════
        return when {
            brand == "lenovo" && model.contains("legion phone duel 2") -> 5500
            brand == "lenovo" && model.contains("legion phone duel")    -> 5000
            brand == "lenovo" && model.contains("k13 note")             -> 6000
            brand == "zte"    && model.contains("axon 40 ultra")        -> 5000
            brand == "zte"    && model.contains("axon 30 ultra")        -> 4600
            brand == "tcl"    && model.contains("40 nxtpaper")          -> 5010
            brand == "tcl"    && model.contains("30 se")                -> 5000
            else -> 0
        }
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
    // CPU TEMPERATURE
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
                val usm    = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                val now    = System.currentTimeMillis()
                val start  = now - 8 * 60 * 60 * 1000L
                val events = usm.queryEvents(start, now)
                val event  = UsageEvents.Event()
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
                    if (type == UsageEvents.Event.MOVE_TO_BACKGROUND) runningPackages.add(pkg)
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

                // ✅ ICON BYTES — yahan se add kiya
                val iconBytes: ByteArray = try {
                    val drawable = pm.getApplicationIcon(ai)
                    val bitmap = if (drawable is android.graphics.drawable.BitmapDrawable) {
                        drawable.bitmap
                    } else {
                        val bmp = android.graphics.Bitmap.createBitmap(
                            drawable.intrinsicWidth.coerceAtLeast(1),
                            drawable.intrinsicHeight.coerceAtLeast(1),
                            android.graphics.Bitmap.Config.ARGB_8888
                        )
                        val canvas = android.graphics.Canvas(bmp)
                        drawable.setBounds(0, 0, canvas.width, canvas.height)
                        drawable.draw(canvas)
                        bmp
                    }
                    val stream = java.io.ByteArrayOutputStream()
                    bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 85, stream)
                    stream.toByteArray()
                } catch (_: Exception) { ByteArray(0) }
                // ✅ ICON BYTES — yahan tak

                mapOf(
                    "packageName" to pkg,
                    "appName"     to pm.getApplicationLabel(ai).toString(),
                    "sizeMb"      to sizeMb,
                    "iconBytes"   to iconBytes   // ← yeh add kiya
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
                val usm    = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                val now    = System.currentTimeMillis()
                val start  = now - 8 * 60 * 60 * 1000L
                val events = usm.queryEvents(start, now)
                val event  = UsageEvents.Event()
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
        val totalMb       = (memInfo.totalMem / 1024 / 1024).toInt()
        val availMb       = (memInfo.availMem / 1024 / 1024).toInt()
        val powerManager  = getSystemService(Context.POWER_SERVICE) as PowerManager
        val thermalStatus = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
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
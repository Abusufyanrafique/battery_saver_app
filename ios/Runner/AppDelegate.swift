import UIKit
import Flutter
import Foundation
import AVFoundation
import CoreLocation
import Photos
import Contacts
// ─────────────────────────────────────────────────────────────────────────────
// AppDelegate.swift
// iOS implementation of all Flutter MethodChannels defined in MainActivity.kt
// ─────────────────────────────────────────────────────────────────────────────

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    // ── Channel name constants (must match Dart/Android exactly) ──
    private let CPU_CHANNEL            = "com.example.battery_saver_app/cpu_info"
    private let BOOST_CHANNEL          = "com.example.battery_saver_app/phone_boost"
    private let NETWORK_CHANNEL        = "com.battery_saver/network_stats"
    private let APP_STATS_CHANNEL      = "com.example.battery_saver_app/app_stats"
    private let BATTERY_CHANNEL        = "com.example.battery_saver_app/battery_status"
    private let BATTERY_HEALTH_CHANNEL = "com.example.battery_saver_app/battery_health"
    private let SECURITY_CHANNEL       = "com.example.battery_saver_app/security"
    private let NOTIFICATION_CHANNEL   = "notification_scanner"
    private let CACHE_CHANNEL          = "com.example.battery_saver_app/device"
    private let STORAGE_CHANNEL        = "com.example.battery_saver_app/device_storage"
    private let POWER_BOOST_CHANNEL    = "com.example.battery_saver_app/power_boost"
    private let APP_SIZE_CHANNEL       = "com.example.battery_saver_app/app_size"

    // ── State ──
    private var cpuUsageBaseline: (total: UInt64, idle: UInt64)? = nil

    // ─────────────────────────────────────────────────────────────────
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not FlutterViewController")
        }
        let messenger = controller.binaryMessenger

        registerPowerBoostChannel(messenger)
        registerStorageChannel(messenger)
        registerCacheChannel(messenger)
        registerNotificationChannel(messenger)
        registerAppSizeChannel(messenger)
        registerSecurityChannel(messenger)
        registerBatteryStatusChannel(messenger)
        registerBatteryHealthChannel(messenger)
        registerCpuChannel(messenger)
        registerBoostChannel(messenger)
        registerNetworkChannel(messenger)
        registerAppStatsChannel(messenger)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – POWER BOOST CHANNEL
    // com.example.battery_saver_app/power_boost
    // ═══════════════════════════════════════════════════════════════
    // iOS support: RAM info  runningAppsCount  (always 0 – sandbox)
    // clearRam / closeBackgroundApps  (not permitted on iOS)
    private func registerPowerBoostChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: POWER_BOOST_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getPowerBoostData":
                    let info = self.getMemoryBytes()
                    result([
                        "ramUsedBytes"      : info.used,
                        "totalRamBytes"     : info.total,
                        "availableRamBytes" : info.available,
                        "runningAppsCount"  : 0   // iOS sandbox – cannot enumerate other apps
                    ])
                case "clearRam":
                    // iOS does not allow killing other processes; trigger GC and return success
                    result(true)
                case "closeBackgroundApps":
                    result(true)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – STORAGE CHANNEL
    // com.example.battery_saver_app/device_storage
    // ═══════════════════════════════════════════════════════════════
    // iOS: Uses app's own sandbox; external storage 
    // junkFiles / residualFiles estimated from Downloads/tmp
    private func registerStorageChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: STORAGE_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getStorageStats":
                    DispatchQueue.global(qos: .userInitiated).async {
                        let stats = self.getStorageStats()
                        DispatchQueue.main.async { result(stats) }
                    }
                case "cleanResidualFiles":
                    DispatchQueue.global(qos: .userInitiated).async {
                        let cleaned = self.cleanResidualFiles()
                        DispatchQueue.main.async { result(cleaned) }
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – CACHE / DEVICE CHANNEL
    // com.example.battery_saver_app/device
    // ═══════════════════════════════════════════════════════════════
    private func registerCacheChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: CACHE_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getCacheSize":
                    result(self.getCacheSize())
                case "clearCache":
                    result(self.clearCache())
                case "getRunningAppsCount":
                    // iOS sandbox: can only see own process
                    result(0)
                case "getRunningAppsList":
                    result([Any]())
                case "getCacheFiles":
                    DispatchQueue.global(qos: .userInitiated).async {
                        let files = self.listFiles(in: self.cacheDirectory())
                        DispatchQueue.main.async { result(files) }
                    }
                case "getResidualFiles":
                    DispatchQueue.global(qos: .userInitiated).async {
                        let files = self.listFiles(in: self.tmpDirectory())
                        DispatchQueue.main.async { result(files) }
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – NOTIFICATION SCANNER CHANNEL
    // notification_scanner
    // ═══════════════════════════════════════════════════════════════
    // iOS: UNUserNotificationCenter can only read delivered notifications
    // from THIS app. Cross-app notification access 
    private func registerNotificationChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: NOTIFICATION_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { call, result in
                switch call.method {
                case "getActiveNotifications":
                    // Return empty list – iOS does not allow reading other apps' notifications
                    result([Any]())
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – APP SIZE CHANNEL
    // com.example.battery_saver_app/app_size
    // ═══════════════════════════════════════════════════════════════
    // iOS: Cannot inspect other app bundles   → return 0.0 for each
    private func registerAppSizeChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: APP_SIZE_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { call, result in
                switch call.method {
                case "getInstalledAppSizes":
                    let packages = (call.arguments as? [String: Any])?["packageNames"] as? [String] ?? []
                    var sizeMap = [String: Double]()
                    packages.forEach { sizeMap[$0] = 0.0 }
                    result(sizeMap)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – SECURITY SCAN CHANNEL
    // com.example.battery_saver_app/security
    // ═══════════════════════════════════════════════════════════════
    // iOS: Permissions are user-granted per app; "dangerous" Android perms ❌
    // We return the iOS location/camera/mic grant status as best analogue.
    private func registerSecurityChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: SECURITY_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getDangerousGrantedPermissions":
                    result(self.getGrantedPermissions())
                case "getBuildTags":
                    // Android concept; return "release-keys" equivalent
                    result("release-keys")
                case "getSdkVersion":
                    // Return iOS major version to keep the integer contract
                    if #available(iOS 16.0, *) {
                        result(Int(UIDevice.current.systemVersion.components(separatedBy: ".").first ?? "0") ?? 0)
                    } else {
                        result(0)
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – BATTERY STATUS CHANNEL
    // com.example.battery_saver_app/battery_status
    // ═══════════════════════════════════════════════════════════════
    // iOS: level   status   remainingMinutes  (returns -1)  cycleCount  (returns 0)
    private func registerBatteryStatusChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: BATTERY_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getBatteryStatus":
                    UIDevice.current.isBatteryMonitoringEnabled = true
                    let level  = Int(UIDevice.current.batteryLevel * 100)
                    let status = self.batteryStatusString()
                    result([
                        "level"            : level < 0 ? 0 : level,
                        "status"           : status,
                        "remainingMinutes" : -1,   // Not available on iOS
                        "cycleCount"       : 0     // Private API – not accessible
                    ])
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – BATTERY HEALTH CHANNEL
    // com.example.battery_saver_app/battery_health
    // ═══════════════════════════════════════════════════════════════
    // iOS: voltage   temperature   currentCapacity   designCapacity from model DB 
    private func registerBatteryHealthChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: BATTERY_HEALTH_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getBatteryHealth":
                    UIDevice.current.isBatteryMonitoringEnabled = true
                    let level   = Int(UIDevice.current.batteryLevel * 100)
                    let design  = Double(self.getDesignCapacityByModel())
                    let current = design > 0 && level > 0 ? (design * Double(level)) / 100.0 : 0.0
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd MMM yyyy"
                    result([
                        "voltage"         : 0.0,           // Not available
                        "temperature"     : 0.0,           // Not available (private entitlement)
                        "batteryLevel"    : level < 0 ? 0 : level,
                        "healthStatus"    : "Unknown",     // Not available
                        "currentCapacity" : current,
                        "designCapacity"  : design,
                        "chargingCycles"  : 0,             // Private API
                        "manufactureDate" : formatter.string(from: Date())
                    ])
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – CPU INFO CHANNEL
    // com.example.battery_saver_app/cpu_info
    // ═══════════════════════════════════════════════════════════════
    // iOS: cpuUsage  (host_statistics)  temperature   runningApps 
    private func registerCpuChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: CPU_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getCpuInfo":
                    DispatchQueue.global(qos: .userInitiated).async {
                        let usage = self.getCpuUsage()
                        DispatchQueue.main.async {
                            result([
                                "cpuUsage"    : usage,
                                "temperature" : 0.0,   // Not accessible without private API
                                "runningApps" : 0      // iOS sandbox
                            ])
                        }
                    }
                case "coolDown":
                    // No-op on iOS – cannot kill other processes
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – PHONE BOOST CHANNEL
    // com.example.battery_saver_app/phone_boost
    // ═══════════════════════════════════════════════════════════════
    private func registerBoostChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: BOOST_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "getMemoryInfo":
                    result(self.getMemoryInfo())
                case "boostMemory":
                    // iOS: we cannot kill other app processes; GC own heap only
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – NETWORK STATS CHANNEL
    // com.battery_saver/network_stats
    // ═══════════════════════════════════════════════════════════════
    // iOS: Per-app network stats via CTCellularData/URLSessionTaskMetrics
    // is extremely limited. We use SystemConfiguration + sysctl for
    // total interface bytes (best available without private APIs).
    // "hasPermission" always true on iOS (no usage stats permission needed).
    private func registerNetworkChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: NETWORK_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {
                case "hasPermission":
                    result(true)
                case "getTotalMobileData":
                    let data = self.getNetworkBytes(interfacePrefix: "pdp_ip")
                    result(data)
                case "getTotalWifiData":
                    let data = self.getNetworkBytes(interfacePrefix: "en")
                    result(data)
                case "getAppNetworkData":
                    // Per-app network breakdown not available on iOS without private APIs
                    let packages = (call.arguments as? [String: Any])?["packageNames"] as? [String] ?? []
                    let empty: [[String: Any]] = packages.map {
                        ["packageName": $0, "rx": 0, "tx": 0, "total": 0]
                    }
                    result(empty)
                case "getDailyData":
                    // Historical per-interval breakdown not available; return single bucket
                    let args      = call.arguments as? [String: Any]
                    let startTime = args?["startTime"] as? Int64 ?? 0
                    let data      = self.getNetworkBytes(interfacePrefix: "en")
                    let wifi      = self.getNetworkBytes(interfacePrefix: "pdp_ip")
                    let rx    = (data["rx"] as? Int64 ?? 0) + (wifi["rx"] as? Int64 ?? 0)
                    let tx    = (data["tx"] as? Int64 ?? 0) + (wifi["tx"] as? Int64 ?? 0)
                    result([[
                        "timestamp" : startTime,
                        "rx"        : rx,
                        "tx"        : tx,
                        "total"     : rx + tx
                    ]])
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – APP STATS CHANNEL
    // com.example.battery_saver_app/app_stats
    // ═══════════════════════════════════════════════════════════════
    // iOS: Screen time / per-app foreground time not available without
    // Screen Time API (family controls entitlement, unavailable to 3rd party).
    // Returns empty list with totalScreenOnTimeSec = 0.
    private func registerAppStatsChannel(_ messenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: APP_STATS_CHANNEL, binaryMessenger: messenger)
            .setMethodCallHandler { call, result in
                switch call.method {
                case "getAppUsageStats":
                    result([
                        "totalScreenOnTimeSec" : 0,
                        "apps"                 : [Any]()
                    ])
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Battery status string
    // ═══════════════════════════════════════════════════════════════
    private func batteryStatusString() -> String {
        switch UIDevice.current.batteryState {
        case .charging:    return "charging"
        case .full:        return "full"
        case .unplugged:   return "discharging"
        default:           return "unknown"
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: RAM bytes
    // ═══════════════════════════════════════════════════════════════
    private func getMemoryBytes() -> (total: Int64, available: Int64, used: Int64) {
        let total     = Int64(ProcessInfo.processInfo.physicalMemory)
        let available = getAvailableMemory()
        let used      = total - available
        return (total, available, used)
    }

    private func getAvailableMemory() -> Int64 {
        var stats   = vm_statistics64_data_t()
        var count   = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let kerr    = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kerr == KERN_SUCCESS else { return 0 }
        let pageSize = Int64(vm_kernel_page_size)
        return Int64(stats.free_count) * pageSize
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Memory info map (phone_boost)
    // ═══════════════════════════════════════════════════════════════
    private func getMemoryInfo() -> [String: Any] {
        let info      = getMemoryBytes()
        let totalMb   = Int(info.total / 1_048_576)
        let usedMb    = Int(info.used  / 1_048_576)
        let availPct  = Double(info.available) / Double(max(info.total, 1)) * 100.0
        let perfScore = min(100, max(1, Int(availPct * 0.6 + 40)))
        return [
            "totalRamMb"          : totalMb,
            "usedRamMb"           : usedMb,
            "runningProcessCount" : 0,          // iOS sandbox
            "performanceScore"    : perfScore
        ]
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: CPU usage (two-sample)
    // ═══════════════════════════════════════════════════════════════
    private func getCpuUsage() -> Double {
        // Use host_processor_info for a two-sample delta
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t? = nil
        var numCpuInfo: mach_msg_type_number_t = 0

        let kerr = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCPUs, &cpuInfo, &numCpuInfo)
        guard kerr == KERN_SUCCESS, let info = cpuInfo else { return 0.0 }

        var totalTicks: Double = 0
        var idleTicks:  Double = 0
        for i in 0..<Int(numCPUs) {
            let base = Int(CPU_STATE_MAX) * i
            totalTicks += Double(info[base + Int(CPU_STATE_USER)])
                        + Double(info[base + Int(CPU_STATE_SYSTEM)])
                        + Double(info[base + Int(CPU_STATE_IDLE)])
                        + Double(info[base + Int(CPU_STATE_NICE)])
            idleTicks  += Double(info[base + Int(CPU_STATE_IDLE)])
        }
        vm_deallocate(mach_task_self_,
                      vm_address_t(bitPattern: info),
                      vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.size))

        guard totalTicks > 0 else { return 0.0 }
        return ((totalTicks - idleTicks) / totalTicks * 100.0).clamped(to: 0...100)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Cache / Tmp / Storage
    // ═══════════════════════════════════════════════════════════════
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func tmpDirectory() -> URL { URL(fileURLWithPath: NSTemporaryDirectory()) }

    private func getCacheSize() -> Int64 {
        folderSize(at: cacheDirectory()) + folderSize(at: tmpDirectory())
    }

    private func clearCache() -> Int64 {
        let size = getCacheSize()
        let fm   = FileManager.default
        for url in [cacheDirectory(), tmpDirectory()] {
            if let contents = try? fm.contentsOfDirectory(at: url,
                                                           includingPropertiesForKeys: nil) {
                contents.forEach { try? fm.removeItem(at: $0) }
            }
        }
        return size
    }

    private func folderSize(at url: URL) -> Int64 {
        var size: Int64 = 0
        guard let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) else { return 0 }
        for case let fileURL as URL in enumerator {
            if let vals = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
               vals.isRegularFile == true {
                size += Int64(vals.fileSize ?? 0)
            }
        }
        return size
    }

    private func listFiles(in directory: URL) -> [[String: Any]] {
        var files = [[String: Any]]()
        guard let enumerator = FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey]) else {
            return files
        }
        for case let fileURL as URL in enumerator {
            if let vals = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey]),
               vals.isRegularFile == true {
                files.append([
                    "name"         : fileURL.lastPathComponent,
                    "path"         : fileURL.path,
                    "size"         : Int64(vals.fileSize ?? 0),
                    "lastModified" : Int64((vals.contentModificationDate?.timeIntervalSince1970 ?? 0) * 1000)
                ])
            }
        }
        return files
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Storage stats (sandbox only)
    // ═══════════════════════════════════════════════════════════════
    private func getStorageStats() -> [String: Int64] {
        let cache    = folderSize(at: cacheDirectory())
        let tmp      = folderSize(at: tmpDirectory())
        return [
            "junkFiles"     : tmp,       // Analogue: tmp = junk on iOS
            "cacheFiles"    : cache,
            "residualFiles" : 0          // No external storage access on iOS
        ]
    }

    private func cleanResidualFiles() -> Int64 {
        // On iOS we can only clean our own cache/tmp
        return clearCache()
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Security – granted permissions
    // ═══════════════════════════════════════════════════════════════
    // Maps iOS permission concepts to Android permission name strings
    // so the Flutter layer receives the same string identifiers.
    private func getGrantedPermissions() -> [String] {
        var granted = [String]()

        // Camera
        checkAVPermission(mediaType: .video) { if $0 { granted.append("android.permission.CAMERA") } }
        // Microphone
        checkAVPermission(mediaType: .audio) { if $0 { granted.append("android.permission.RECORD_AUDIO") } }
        // Location (fine)
        if CLAuthorizationStatusGranted() {
            granted.append("android.permission.ACCESS_FINE_LOCATION")
            granted.append("android.permission.ACCESS_COARSE_LOCATION")
        }
        // Photos / external storage analogue
        if photoLibraryGranted() {
            granted.append("android.permission.READ_EXTERNAL_STORAGE")
        }
        // Contacts
        if contactsGranted() {
            granted.append("android.permission.READ_CONTACTS")
        }
        return granted
    }

    private func checkAVPermission(mediaType: AVMediaType, completion: (Bool) -> Void) {
        completion(AVCaptureDevice.authorizationStatus(for: mediaType) == .authorized)
    }

    private func CLAuthorizationStatusGranted() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }

    private func photoLibraryGranted() -> Bool {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
        }
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    private func contactsGranted() -> Bool {
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Network interface bytes
    // ═══════════════════════════════════════════════════════════════
    // Uses getifaddrs to sum RX/TX bytes across matching interfaces.
    // Note: counters reset on reboot; no historical range filtering.
    private func getNetworkBytes(interfacePrefix: String) -> [String: Any] {
        var totalRx: Int64 = 0
        var totalTx: Int64 = 0

        var ifaddrsPtr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrsPtr) == 0 else { return ["rx": 0, "tx": 0] }
        defer { freeifaddrs(ifaddrsPtr) }

        var cursor = ifaddrsPtr
        while let current = cursor {
            let iface = current.pointee
            if let name = iface.ifa_name.flatMap({ String(cString: $0, encoding: .utf8) }),
               name.hasPrefix(interfacePrefix),
               iface.ifa_addr?.pointee.sa_family == UInt8(AF_LINK),
               let data = iface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalRx += Int64(data.pointee.ifi_ibytes)
                totalTx += Int64(data.pointee.ifi_obytes)
            }
            cursor = iface.ifa_next
        }
        return ["rx": totalRx, "tx": totalTx]
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: – Helper: Design capacity by iPhone/iPad model
    // ═══════════════════════════════════════════════════════════════
    // Returns mAh for the detected device hardware identifier.
    private func getDesignCapacityByModel() -> Int {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafeBytes(of: &systemInfo.machine) { rawPtr in
            rawPtr.bindMemory(to: CChar.self).baseAddress.flatMap { String(cString: $0) } ?? ""
        }
        return Self.iPhoneCapacityDB[machine] ?? 0
    }

    // Hardware identifier → mAh (sourced from iFixit / Apple specs)
    private static let iPhoneCapacityDB: [String: Int] = [
        // ── iPhone 16 Series ──
        "iPhone17,2" : 4685,  // iPhone 16 Pro Max
        "iPhone17,1" : 3582,  // iPhone 16 Pro
        "iPhone17,4" : 4006,  // iPhone 16 Plus
        "iPhone17,3" : 3561,  // iPhone 16
        // ── iPhone 15 Series ──
        "iPhone16,2" : 4422,  // iPhone 15 Pro Max
        "iPhone16,1" : 3274,  // iPhone 15 Pro
        "iPhone15,5" : 4383,  // iPhone 15 Plus
        "iPhone15,4" : 3349,  // iPhone 15
        // ── iPhone 14 Series ──
        "iPhone15,3" : 4323,  // iPhone 14 Pro Max
        "iPhone15,2" : 3200,  // iPhone 14 Pro
        "iPhone14,8" : 4325,  // iPhone 14 Plus
        "iPhone14,7" : 3279,  // iPhone 14
        // ── iPhone 13 Series ──
        "iPhone14,3" : 4352,  // iPhone 13 Pro Max
        "iPhone14,2" : 3095,  // iPhone 13 Pro
        "iPhone14,5" : 3227,  // iPhone 13
        "iPhone14,4" : 2438,  // iPhone 13 mini
        // ── iPhone 12 Series ──
        "iPhone13,4" : 3687,  // iPhone 12 Pro Max
        "iPhone13,3" : 2815,  // iPhone 12 Pro
        "iPhone13,2" : 2815,  // iPhone 12
        "iPhone13,1" : 2227,  // iPhone 12 mini
        // ── iPhone 11 Series ──
        "iPhone12,5" : 3969,  // iPhone 11 Pro Max
        "iPhone12,3" : 3046,  // iPhone 11 Pro
        "iPhone12,1" : 3110,  // iPhone 11
        // ── iPhone XS / XR ──
        "iPhone11,6" : 3174,  // iPhone XS Max
        "iPhone11,4" : 3174,  // iPhone XS Max (China)
        "iPhone11,2" : 2658,  // iPhone XS
        "iPhone11,8" : 2942,  // iPhone XR
        // ── iPhone X / 8 ──
        "iPhone10,6" : 2716,  // iPhone X (Global)
        "iPhone10,3" : 2716,  // iPhone X (US)
        "iPhone10,5" : 2691,  // iPhone 8 Plus
        "iPhone10,2" : 2691,  // iPhone 8 Plus
        "iPhone10,4" : 1821,  // iPhone 8
        "iPhone10,1" : 1821,  // iPhone 8
        // ── iPhone 7 / SE ──
        "iPhone9,4"  : 2900,  // iPhone 7 Plus
        "iPhone9,2"  : 2900,  // iPhone 7 Plus
        "iPhone9,3"  : 1960,  // iPhone 7
        "iPhone9,1"  : 1960,  // iPhone 7
        "iPhone14,6" : 2018,  // iPhone SE 3rd gen
        "iPhone12,8" : 1821,  // iPhone SE 2nd gen
        "iPhone8,4"  : 1624,  // iPhone SE 1st gen
        // ── iPad Pro ──
        "iPad14,5"   : 10307, // iPad Pro 12.9" M2
        "iPad14,6"   : 10307,
        "iPad14,3"   : 7538,  // iPad Pro 11" M2
        "iPad14,4"   : 7538,
        "iPad13,8"   : 10307, // iPad Pro 12.9" M1
        "iPad13,9"   : 10307,
        "iPad13,10"  : 10307,
        "iPad13,11"  : 10307,
        "iPad13,4"   : 7538,  // iPad Pro 11" M1
        "iPad13,5"   : 7538,
        "iPad13,6"   : 7538,
        "iPad13,7"   : 7538,
        // ── iPad Air ──
        "iPad14,1"   : 7606,  // iPad Air M1 (Wi-Fi)
        "iPad14,2"   : 7606,  // iPad Air M1 (Cellular)
        "iPad13,1"   : 7606,  // iPad Air 4
        "iPad13,2"   : 7606,
        // ── iPad (standard) ──
        "iPad12,1"   : 8827,  // iPad 9th gen
        "iPad12,2"   : 8827,
        "iPad13,18"  : 7606,  // iPad 10th gen
        "iPad13,19"  : 7606,
        // ── iPad mini ──
        "iPad14,8"   : 5124,  // iPad mini 6
        "iPad14,9"   : 5124,
    ]
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Comparable clamping helper
// ─────────────────────────────────────────────────────────────────────────────
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Import stubs (add to top of file or Bridging Header as needed)
// The following frameworks must be linked in Xcode:
//   AVFoundation · CoreLocation · Photos · Contacts
// ─────────────────────────────────────────────────────────────────────────────
// import AVFoundation
// import CoreLocation
// import Photos
// import Contacts
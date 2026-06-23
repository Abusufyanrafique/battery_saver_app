import 'package:flutter/services.dart';

/// Flutter-side bridge to the native Android helper classes.
/// All methods map directly to the Kotlin helpers:
///   BrightnessHelper, BackgroundAppsHelper, AutoSyncHelper,
///   NotificationHelper, PowerSaverHelper, BatteryHelper
class BatterySaverChannel {
  static const MethodChannel _channel = MethodChannel('battery_optimizer');

  // ─── Battery Info ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getBatteryInfo() async {
    final result = await _channel.invokeMethod<Map>('getBatteryInfo');
    return Map<String, dynamic>.from(result ?? {});
  }

  // ─── Brightness ────────────────────────────────────────────────────────────

  /// Returns current brightness (0–255) or -1 if unavailable.
  static Future<int> getBrightness() async {
    return await _channel.invokeMethod<int>('getBrightness') ?? -1;
  }

  /// Sets brightness (0–255).
  /// Returns true on success, false if WRITE_SETTINGS permission not granted.
  static Future<bool> setBrightness(int value) async {
    return await _channel.invokeMethod<bool>('setBrightness', {'value': value}) ?? false;
  }

  /// Returns whether the app has WRITE_SETTINGS permission.
  static Future<bool> hasWriteSettingsPermission() async {
    return await _channel.invokeMethod<bool>('hasWriteSettingsPermission') ?? false;
  }

  /// Opens system screen so user can grant "Modify system settings".
  static Future<void> requestWriteSettingsPermission() async {
    await _channel.invokeMethod('requestWriteSettingsPermission');
  }

  // ─── Background Apps ───────────────────────────────────────────────────────

  /// Returns whether THIS app is background-restricted (API 28+).
  static Future<bool> isBackgroundRestricted() async {
    return await _channel.invokeMethod<bool>('isBackgroundRestricted') ?? false;
  }

  /// Opens this app's "App info" page so the user can manage background usage.
  static Future<void> openBackgroundAppsSettings() async {
    await _channel.invokeMethod('openBackgroundAppsSettings');
  }

  // ─── Auto Sync ─────────────────────────────────────────────────────────────

  /// Returns the current master auto-sync state.
  static Future<bool> isAutoSyncEnabled() async {
    return await _channel.invokeMethod<bool>('isAutoSyncEnabled') ?? true;
  }

  /// Enables or disables master auto-sync (no permission needed).
  static Future<void> setAutoSyncEnabled(bool enabled) async {
    await _channel.invokeMethod('setAutoSyncEnabled', {'enabled': enabled});
  }

  // ─── Notifications / DND ───────────────────────────────────────────────────

  /// Returns whether notification policy (DND) access has been granted.
  static Future<bool> isNotificationPolicyAccessGranted() async {
    return await _channel.invokeMethod<bool>('isNotificationPolicyAccessGranted') ?? false;
  }

  /// Opens system screen to grant DND/notification policy access.
  static Future<void> requestNotificationPolicyAccess() async {
    await _channel.invokeMethod('requestNotificationPolicyAccess');
  }

  /// Sets DND mode.
  /// [limited] = true → Priority only ("Limited")
  /// [limited] = false → All notifications ("Normal")
  /// Returns false if policy access not granted.
  static Future<bool> setNotificationsLimited(bool limited) async {
    return await _channel.invokeMethod<bool>(
          'setNotificationsLimited',
          {'limited': limited},
        ) ??
        false;
  }

  /// Returns current notification status: "Normal", "Limited", or "Disabled".
  static Future<String> getNotificationStatus() async {
    return await _channel.invokeMethod<String>('getNotificationStatus') ?? 'Unknown';
  }

  // ─── Power Saver ───────────────────────────────────────────────────────────

  /// Returns whether the OS Battery Saver (power save mode) is currently on.
  static Future<bool> isPowerSaverEnabled() async {
    return await _channel.invokeMethod<bool>('isPowerSaverEnabled') ?? false;
  }

  /// Deep-links to system Battery Saver settings (user must toggle manually).
  static Future<void> openPowerSaverSettings() async {
    await _channel.invokeMethod('openPowerSaverSettings');
  }
}
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class SettingsLauncher {
  // -------------------------------------------------------------------------
  // Public methods - call these from your UI
  // -------------------------------------------------------------------------

  static Future<void> openAutoOptimizeSettings(BuildContext context) async {
    await _openAndroidSettings(
      context,
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
    );
  }

  static Future<void> openBatterySaverSettings(BuildContext context) async {
    final shouldProceed = await _showManualToggleHint(
      context,
      title: 'One more tap needed',
      message:
          'Android requires you to turn on Battery Saver yourself for security reasons. '
          'We\'ll open the settings screen — just tap the switch there.',
    );
    if (shouldProceed != true) return;

    await _openAndroidSettings(
      context,
      action: 'android.settings.BATTERY_SAVER_SETTINGS',
    );
  }

  static Future<void> openAppManagerSettings(BuildContext context) async {
    await _openAndroidSettings(
      context,
      action: 'android.settings.APPLICATION_SETTINGS',
    );
  }

  // -------------------------------------------------------------------------
  // Private implementation
  // -------------------------------------------------------------------------

  static Future<bool?> _showManualToggleHint(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openAndroidSettings(
    BuildContext context, {
    required String action,
    String? package,
  }) async {
    try {
      final intent = AndroidIntent(
        action: action,
        package: package,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open settings: $e')),
        );
      }
      // Fallback to general settings page
      try {
        const fallback = AndroidIntent(
          action: 'android.settings.SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await fallback.launch();
      } catch (_) {
        // Nothing more we can do — device/OEM is blocking all intents
      }
    }
  }
}
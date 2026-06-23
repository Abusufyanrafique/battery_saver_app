// real_profile_repository.dart

import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:battery_saver_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealProfileRepository implements ProfileRepository {
  final Battery _battery = Battery();

  // ── SharedPrefs Keys ──────────────────────────────────────
  static const _kPrevLevel    = 'battery_prev_level';
  static const _kCycles       = 'battery_charging_cycles';
  static const _kLastFullTime = 'battery_last_full_time';

  // ── Android MethodChannel ─────────────────────────────────
  static const _channel = MethodChannel('battery_info');

  // ─────────────────────────────────────────────────────────
  // MAIN FETCH
  // ─────────────────────────────────────────────────────────

  @override
  Future<ProfileData> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // ── 1. Battery Level ──────────────────────────────────
    final int level = await _battery.batteryLevel;

    // ── 2. Charging State ─────────────────────────────────
    final BatteryState batteryState = await _battery.batteryState;
    final bool isCharging =
        batteryState == BatteryState.charging ||
        batteryState == BatteryState.full;

    // ── 3. Remaining Time ─────────────────────────────────
    // UPDATED: native se real value
    final String remainingTime = await _getRealRemainingTime(
      level: level,
      isCharging: isCharging,
    );

    // ── 4. Charging Cycles ────────────────────────────────
    final int cycles = await _getChargingCycles(
      prefs: prefs,
      level: level,
      isCharging: isCharging,
    );

    // ── 5. Efficiency ─────────────────────────────────────
    //  UPDATED: native se real value
    final int efficiency = await _getRealEfficiency();

    // ── 6. Battery Drain ──────────────────────────────────
    final int drain = await _calculateDrain(
      prefs: prefs,
      currentLevel: level,
      isCharging: isCharging,
    );

    return ProfileData(
      // ── User fields ───────────────────────────────────
      name: 'Abu Sufyan',
      email: 'abusufyan@gmail.com',
      memberSince: 'Jan 2024',
      isPremium: true,
      profileScore: 92,
      scoreLabel: 'Excellent',

      // ── Real battery fields ───────────────────────────
      batteryLife: remainingTime,
      chargingCycles: cycles,
      efficiency: efficiency,
      batteryDrain: drain,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // ─────────────────────────────────────────────────────────
  // HELPER 1 — Real Remaining Time (native first)
  // ─────────────────────────────────────────────────────────

  Future<String> _getRealRemainingTime({
    required int level,
    required bool isCharging,
  }) async {
    if (isCharging) return 'Charging…';
    if (level <= 0) return '0m';

    try {
      //  Android OS se exact minutes
      final int? minutes =
          await _channel.invokeMethod<int>('getRemainingTime');

      if (minutes != null && minutes > 0) {
        final int h = minutes ~/ 60;
        final int m = minutes % 60;
        return h == 0 ? '${m}m' : '${h}h ${m}m';  // real value
      }
    } catch (_) {
      // iOS ya unsupported — fallback chalega
    }

    // Fallback — estimate (7 min per %)
    final int totalMinutes = level * 7;
    final int hours   = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
  }

  // ─────────────────────────────────────────────────────────
  // HELPER 2 — Charging Cycles (same as before)
  // ─────────────────────────────────────────────────────────

  Future<int> _getChargingCycles({
    required SharedPreferences prefs,
    required int level,
    required bool isCharging,
  }) async {
    try {
      final int? native =
          await _channel.invokeMethod<int>('getChargingCycles');
      if (native != null && native > 0) return native;
    } catch (_) {}

    int cycles = prefs.getInt(_kCycles) ?? 0;

    if (isCharging && level >= 95) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int lastFull = prefs.getInt(_kLastFullTime) ?? 0;
      final int diffMin = (now - lastFull) ~/ 60000;

      if (diffMin > 30) {
        cycles++;
        await prefs.setInt(_kCycles, cycles);
        await prefs.setInt(_kLastFullTime, now);
      }
    }

    return cycles;
  }

  // ─────────────────────────────────────────────────────────
  // HELPER 3 — Real Efficiency (native first)
  // ─────────────────────────────────────────────────────────

  Future<int> _getRealEfficiency() async {
    try {
      //  Android Intent se real battery health
      final int? health =
          await _channel.invokeMethod<int>('getEfficiency');

      if (health != null && health > 0) return health;  // real value
    } catch (_) {
      // iOS ya unsupported — fallback chalega
    }

    // Fallback — estimated (purana logic)
    final int level = await _battery.batteryLevel;
    final BatteryState state = await _battery.batteryState;
    final bool isCharging =
        state == BatteryState.charging || state == BatteryState.full;

    if (isCharging)  return 95 + ((level / 100) * 5).round();
    if (level > 60)  return 75 + ((level - 60) / 40 * 25).round();
    if (level > 30)  return 55 + ((level - 30) / 30 * 20).round();
    return           40 + ((level / 30) * 15).round();
  }

  // ─────────────────────────────────────────────────────────
  // HELPER 4 — Battery Drain (same as before)
  // ─────────────────────────────────────────────────────────

  Future<int> _calculateDrain({
    required SharedPreferences prefs,
    required int currentLevel,
    required bool isCharging,
  }) async {
    if (isCharging) {
      await prefs.setInt(_kPrevLevel, currentLevel);
      return 0;
    }

    final int? prevLevel = prefs.getInt(_kPrevLevel);

    if (prevLevel == null) {
      await prefs.setInt(_kPrevLevel, currentLevel);
      return 0;
    }

    final int drain = currentLevel - prevLevel;
    await prefs.setInt(_kPrevLevel, currentLevel);
    return drain;
  }
}
package com.example.battery_saver_app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.MethodChannel

class BatteryInfoHandler(private val context: Context) {

    fun register(channel: MethodChannel) {

        channel.setMethodCallHandler { call, result ->
            when (call.method) {

                "getChargingCycles" -> {
                    val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val cycles = bm.getIntProperty(
                        BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER
                    )
                    result.success(cycles)
                }

                // ── NEW: Real Remaining Time ──────────────────────
                "getRemainingTime" -> {
                    val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager

                    // Android OS ka real remaining time (milliseconds)
                    val timeMs = bm.computeChargeTimeRemaining()

                    if (timeMs > 0) {
                        // Real value mili — minutes mein convert karo
                        val minutes = (timeMs / 60000).toInt()
                        result.success(minutes)
                    } else {
                        // OS ne -1 diya — manual estimate karo
                        val level = bm.getIntProperty(
                            BatteryManager.BATTERY_PROPERTY_CAPACITY
                        )
                        result.success(level * 7) // fallback: 7 min per %
                    }
                }

                // ── NEW: Real Efficiency (Battery Health) ─────────
                "getEfficiency" -> {
                    // BatteryManager se health nahi milti — Intent use karo
                    val intent = context.registerReceiver(
                        null,
                        IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                    )

                    val health = intent?.getIntExtra(
                        BatteryManager.EXTRA_HEALTH,
                        BatteryManager.BATTERY_HEALTH_UNKNOWN
                    ) ?: BatteryManager.BATTERY_HEALTH_UNKNOWN

                    // Health code ko % mein convert karo
                    val efficiencyPercent = when (health) {
                        BatteryManager.BATTERY_HEALTH_GOOD          -> 95
                        BatteryManager.BATTERY_HEALTH_COLD          -> 70
                        BatteryManager.BATTERY_HEALTH_DEAD          -> 10
                        BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE  -> 40
                        BatteryManager.BATTERY_HEALTH_OVERHEAT      -> 30
                        BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> 20
                        else                                         -> 75
                    }

                    result.success(efficiencyPercent)
                }

                else -> result.notImplemented()
            }
        }
    }
}
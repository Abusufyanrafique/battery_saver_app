package com.example.battery_saver_app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import kotlin.math.roundToInt

/**
 * Handles everything related to reading battery state and estimating
 * remaining time.
 *
 * IMPORTANT: Android does NOT expose a public API for "time remaining while
 * discharging" — that value is only available internally to the OS/Settings
 * app. What we CAN get from BatteryManager:
 *   - computeChargeTimeRemaining() -> only valid while CHARGING, returns ms or -1.
 * For discharging, we estimate using level + a simple drain-rate sample taken
 * across calls. This is an approximation, the same approach most 3rd-party
 * battery apps use.
 */
class BatteryHelper(private val context: Context) {

    // Used to estimate discharge rate between two calls (simple moving estimate)
    private var lastLevel: Int? = null
    private var lastTimestamp: Long = 0L

    fun getBatteryInfo(): Map<String, Any> {
        val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))

        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val pct = if (level >= 0 && scale > 0) (level * 100 / scale) else -1

        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL

        val batteryManager =
            context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager

        var minutesRemaining: Int
        val source: String

        if (isCharging) {
            // Real OS value, only available while charging (API 28+)
            val chargeTimeMs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                batteryManager.computeChargeTimeRemaining()
            } else -1L

            if (chargeTimeMs > 0) {
                minutesRemaining = (chargeTimeMs / 60000).toInt()
                source = "system_charge_estimate"
            } else {
                minutesRemaining = estimateMinutesFromLevel(pct)
                source = "fallback_estimate"
            }
        } else {
            minutesRemaining = estimateDischargeMinutes(pct)
            source = "drain_rate_estimate"
        }

        val hours = minutesRemaining / 60
        val mins = minutesRemaining % 60

        val statusLabel = when {
            pct >= 60 -> "Extended"
            pct >= 25 -> "Normal"
            else -> "Limited"
        }

        return mapOf(
            "level" to pct,
            "isCharging" to isCharging,
            "minutesRemaining" to minutesRemaining,
            "hoursPart" to hours,
            "minutesPart" to mins,
            "statusLabel" to statusLabel,
            "estimateSource" to source
        )
    }

    /** Naive fallback: tuned guess -> ~100% lasts ~9h average mixed use. */
    private fun estimateMinutesFromLevel(pct: Int): Int {
        if (pct <= 0) return 0
        val avgDrainPerMinute = 0.18
        return (pct / avgDrainPerMinute).roundToInt()
    }

    /**
     * Tracks level drop between consecutive calls to estimate a real drain rate.
     * Falls back to the naive estimate on first call or if no measurable drop yet.
     */
    private fun estimateDischargeMinutes(pct: Int): Int {
        val now = System.currentTimeMillis()
        val prevLevel = lastLevel
        val prevTime = lastTimestamp

        var minutesRemaining = estimateMinutesFromLevel(pct)

        if (prevLevel != null && prevLevel > pct && prevTime > 0) {
            val elapsedMinutes = (now - prevTime) / 60000.0
            val levelDrop = prevLevel - pct
            if (elapsedMinutes > 0.5 && levelDrop > 0) {
                val ratePerMinute = levelDrop / elapsedMinutes
                if (ratePerMinute > 0) {
                    minutesRemaining = (pct / ratePerMinute).roundToInt()
                }
            }
        }

        lastLevel = pct
        lastTimestamp = now
        return minutesRemaining
    }
}
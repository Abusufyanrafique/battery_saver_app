package com.example.battery_saver_app

import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.provider.Settings

/**
 * Handles Battery Saver (Power Save Mode).
 *
 * Android does NOT allow 3rd-party apps to silently enable Battery Saver —
 * this is a deliberate OS restriction. We can only read its current state
 * and deep-link the user to the system settings screen to toggle it manually.
 */
class PowerSaverHelper(private val context: Context) {

    fun isPowerSaverEnabled(): Boolean {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isPowerSaveMode
    }

    /** Opens the system Battery Saver settings screen. */
    fun openPowerSaverSettings() {
        val intent = Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
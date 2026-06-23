package com.example.battery_saver_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/**
 * Handles reading and writing screen brightness.
 * Writing requires the WRITE_SETTINGS special permission, which the user
 * must grant manually via a system screen (cannot be granted silently).
 */
class BrightnessHelper(private val context: Context) {

    fun getBrightness(): Int {
        return Settings.System.getInt(
            context.contentResolver,
            Settings.System.SCREEN_BRIGHTNESS,
            128
        )
    }

    /** value: 0-255. Returns false if permission is not granted. */
    fun setBrightness(value: Int): Boolean {
        if (!hasWriteSettingsPermission()) return false
        val clamped = value.coerceIn(0, 255)
        return try {
            Settings.System.putInt(
                context.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS,
                clamped
            )
            true
        } catch (e: SecurityException) {
            false
        }
    }

    fun hasWriteSettingsPermission(): Boolean {
        return Settings.System.canWrite(context)
    }

    /** Opens the system screen where the user grants "Modify system settings". */
    fun requestWriteSettingsPermission() {
        val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
            data = Uri.parse("package:${context.packageName}")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
package com.example.battery_saver_app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.provider.Settings

/**
 * Handles notifications via Do Not Disturb (interruption filter).
 *
 * Requires the user to grant "Notification policy access" once via a
 * system settings screen. After that, DND mode CAN be toggled
 * programmatically without further prompts.
 */
class NotificationHelper(private val context: Context) {

    private fun manager(): NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    fun isNotificationPolicyAccessGranted(): Boolean {
        return manager().isNotificationPolicyAccessGranted
    }

    /** Opens the system screen where the user grants DND/notification policy access. */
    fun requestNotificationPolicyAccess() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    /**
     * limited = true  -> DND "Priority only" (maps to "Limited" in the UI)
     * limited = false -> All notifications allowed ("Normal")
     * Returns false if policy access has not been granted yet.
     */
    fun setNotificationsLimited(limited: Boolean): Boolean {
        if (!isNotificationPolicyAccessGranted()) return false
        return try {
            manager().setInterruptionFilter(
                if (limited) NotificationManager.INTERRUPTION_FILTER_PRIORITY
                else NotificationManager.INTERRUPTION_FILTER_ALL
            )
            true
        } catch (e: SecurityException) {
            false
        }
    }

    fun getNotificationStatus(): String {
        return when (manager().currentInterruptionFilter) {
            NotificationManager.INTERRUPTION_FILTER_ALL -> "Normal"
            NotificationManager.INTERRUPTION_FILTER_PRIORITY -> "Limited"
            NotificationManager.INTERRUPTION_FILTER_NONE -> "Disabled"
            NotificationManager.INTERRUPTION_FILTER_ALARMS -> "Limited"
            else -> "Unknown"
        }
    }
}
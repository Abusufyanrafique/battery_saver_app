package com.example.battery_saver_app

import android.content.ContentResolver

/**
 * Handles the system-wide "Auto Sync" (master sync) setting.
 * Unlike Power Saver or Background Apps, this CAN be toggled directly
 * with no special permission or settings screen required.
 */
class AutoSyncHelper {

    fun isAutoSyncEnabled(): Boolean {
        return ContentResolver.getMasterSyncAutomatically()
    }

    fun setAutoSyncEnabled(enabled: Boolean) {
        ContentResolver.setMasterSyncAutomatically(enabled)
    }
}
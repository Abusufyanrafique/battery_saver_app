package com.example.battery_saver_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

/**
 * Handles "Background Apps" restriction status.
 *
 * Android does NOT let a 3rd-party app restrict OTHER apps' background
 * activity — that would be a serious security/privacy violation. We can
 * only read OUR OWN app's restriction state and deep-link the user to the
 * per-app battery/details settings screen for manual action.
 */
class BackgroundAppsHelper(private val context: Context) {

    fun isBackgroundRestricted(): Boolean {
        val activityManager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            activityManager.isBackgroundRestricted
        } else {
            false
        }
    }

    /** Opens this app's "App info" screen, where the user can manage battery/background usage. */
    fun openBackgroundAppsSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:${context.packageName}")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
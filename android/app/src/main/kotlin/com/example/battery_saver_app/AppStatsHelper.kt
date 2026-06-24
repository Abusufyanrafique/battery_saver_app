package com.example.battery_saver_app

import android.app.ActivityManager
import android.content.Context

class AppStatsHelper {

    fun closeBackgroundApps(context: Context): Map<String, Any> {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val packageManager = context.packageManager

        val runningProcesses = activityManager.runningAppProcesses ?: emptyList()

        var closedCount = 0
        val closedAppNames = mutableListOf<String>()

        for (process in runningProcesses) {

            if (process.processName == context.packageName) continue

            if (process.importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND) {
                try {
                    activityManager.killBackgroundProcesses(process.processName)
                    closedCount++

                    val appName = try {
                        val appInfo = packageManager.getApplicationInfo(process.processName, 0)
                        packageManager.getApplicationLabel(appInfo).toString()
                    } catch (e: Exception) {
                        process.processName
                    }

                    closedAppNames.add(appName)

                } catch (e: Exception) {
                    // skip system apps
                }
            }
        }

        return mapOf(
            "closedCount" to closedCount,
            "closedApps" to closedAppNames
        )
    }
}
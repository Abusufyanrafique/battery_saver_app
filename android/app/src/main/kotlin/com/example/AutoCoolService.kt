package com.example.battery_saver_app

import android.app.Service
import android.app.ActivityManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

class AutoCoolService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private val CHECK_INTERVAL = 60_000L // 60 seconds

    private val tempCheckRunnable = object : Runnable {
        override fun run() {

            val temp = getBatteryTemperature()

            // 🔥 threshold check
            if (temp > 40f) {
                killHeavyApps()
            }

            handler.postDelayed(this, CHECK_INTERVAL)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        startForeground(NOTIF_ID, buildNotification())

        handler.post(tempCheckRunnable)

        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tempCheckRunnable)
        super.onDestroy()
    }

    // 🔋 REAL BATTERY TEMPERATURE
    private fun getBatteryTemperature(): Float {
        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val temp = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1

        if (temp == -1) return 0f

        return temp / 10f
    }

    // ⚠️ SAFE BACKGROUND APP KILLING (LIMITED BY ANDROID)
    private fun killHeavyApps() {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val processes = am.runningAppProcesses ?: return

        for (process in processes) {

            if (process.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND) {
                am.killBackgroundProcesses(process.processName)
            }
        }
    }

    // 🔔 FOREGROUND NOTIFICATION
    private fun buildNotification(): Notification {

        val channelId = "auto_cool_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                channelId,
                "Auto Cool Service",
                NotificationManager.IMPORTANCE_LOW
            )

            val manager =
                getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Auto Cool Active")
            .setContentText("Monitoring device temperature")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val NOTIF_ID = 101
    }
}
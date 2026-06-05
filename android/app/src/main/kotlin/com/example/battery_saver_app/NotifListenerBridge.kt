package com.example.battery_saver_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotifListenerBridge : NotificationListenerService() {

    override fun onListenerConnected() {
        instance = this
    }

    override fun onListenerDisconnected() {
        instance = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {}
    override fun onNotificationRemoved(sbn: StatusBarNotification?) {}

    companion object {
        var instance: NotifListenerBridge? = null
    }
}
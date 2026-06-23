package com.example.battery_saver_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Build

class NotifListenerBridge : NotificationListenerService() {

    // ─────────────────────────────────────────────────────────────────────────
    // In-memory store: packageName → notification count
    // ─────────────────────────────────────────────────────────────────────────
    private val notifCountMap = mutableMapOf<String, Int>()

    // Spam threshold — ek app se itni ya zyada notifications = suspicious
    companion object {
        private const val SPAM_THRESHOLD = 5

        var instance: NotifListenerBridge? = null

        // ─────────────────────────────────────────────────────────────────────
        // 1. TOTAL ACTIVE NOTIFICATIONS COUNT
        // ─────────────────────────────────────────────────────────────────────
        fun getActiveNotificationCount(): Int {
            return try {
                instance?.activeNotifications?.size ?: 0
            } catch (e: Exception) {
                0
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // 2. PER-APP NOTIFICATION COUNT
        //    Returns list of maps: {appPackage, count}
        // ─────────────────────────────────────────────────────────────────────
        fun getNotificationCountPerApp(): List<Map<String, Any>> {
            return try {
                val notifications = instance?.activeNotifications ?: return emptyList()
                val countMap = mutableMapOf<String, Int>()

                for (sbn in notifications) {
                    val pkg = sbn.packageName ?: continue
                    countMap[pkg] = (countMap[pkg] ?: 0) + 1
                }

                countMap.map { (pkg, count) ->
                    mapOf("package" to pkg, "count" to count)
                }.sortedByDescending { it["count"] as Int }

            } catch (e: Exception) {
                emptyList()
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // 3. SUSPICIOUS / SPAM APPS
        //    Apps jo SPAM_THRESHOLD se zyada notifications bhej rahe hain
        // ─────────────────────────────────────────────────────────────────────
        fun getSuspiciousNotificationApps(): List<Map<String, Any>> {
            return try {
                val notifications = instance?.activeNotifications ?: return emptyList()
                val countMap = mutableMapOf<String, Int>()

                for (sbn in notifications) {
                    val pkg = sbn.packageName ?: continue
                    countMap[pkg] = (countMap[pkg] ?: 0) + 1
                }

                countMap
                    .filter { it.value >= SPAM_THRESHOLD }
                    .map { (pkg, count) ->
                        mapOf(
                            "package" to pkg,
                            "count"   to count,
                            "risk"    to when {
                                count >= 15 -> "high"
                                count >= 10 -> "medium"
                                else        -> "low"
                            }
                        )
                    }
                    .sortedByDescending { it["count"] as Int }

            } catch (e: Exception) {
                emptyList()
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // 4. CANCEL — specific app ki saari notifications hatao
        // ─────────────────────────────────────────────────────────────────────
        fun cancelNotificationsForPackage(packageName: String): Boolean {
            return try {
                val bridge = instance ?: return false
                val toCancel = bridge.activeNotifications
                    ?.filter { it.packageName == packageName }
                    ?: return false

                for (sbn in toCancel) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        bridge.cancelNotification(sbn.key)
                    } else {
                        @Suppress("DEPRECATION")
                        bridge.cancelNotification(sbn.packageName, sbn.tag, sbn.id)
                    }
                }
                true
            } catch (e: Exception) {
                false
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // 5. CANCEL ALL — saari notifications ek saath hatao
        // ─────────────────────────────────────────────────────────────────────
        fun cancelAllNotifications(): Boolean {
            return try {
                instance?.cancelAllNotifications()
                true
            } catch (e: Exception) {
                false
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // 6. FULL SUMMARY — ek call mein sab kuch
        // ─────────────────────────────────────────────────────────────────────
        fun getNotificationSummary(): Map<String, Any> {
            return try {
                val notifications = instance?.activeNotifications ?: emptyArray()
                val countMap = mutableMapOf<String, Int>()

                for (sbn in notifications) {
                    val pkg = sbn.packageName ?: continue
                    countMap[pkg] = (countMap[pkg] ?: 0) + 1
                }

                val spamApps = countMap.filter { it.value >= SPAM_THRESHOLD }

                mapOf(
                    "totalNotifications" to notifications.size,
                    "totalApps"          to countMap.size,
                    "spamAppsCount"      to spamApps.size,
                    "isListenerActive"   to (instance != null)
                )
            } catch (e: Exception) {
                mapOf(
                    "totalNotifications" to 0,
                    "totalApps"          to 0,
                    "spamAppsCount"      to 0,
                    "isListenerActive"   to false
                )
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────────────────────────────────
    override fun onListenerConnected() {
        instance = this
    }

    override fun onListenerDisconnected() {
        instance = null
    }

    // Live tracking — notifCountMap update karo
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val pkg = sbn?.packageName ?: return
        notifCountMap[pkg] = (notifCountMap[pkg] ?: 0) + 1
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        val pkg = sbn?.packageName ?: return
        val current = notifCountMap[pkg] ?: return
        if (current <= 1) {
            notifCountMap.remove(pkg)
        } else {
            notifCountMap[pkg] = current - 1
        }
    }
}
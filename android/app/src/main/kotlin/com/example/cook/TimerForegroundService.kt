package com.example.cook

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class TimerForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "timer_channel"
        const val CHANNEL_FINISH_ID = "timer_finish_channel"
        const val NOTIFICATION_ID = 1001
        const val NOTIFICATION_FINISH_ID = 1002
        const val ACTION_START = "ACTION_START"
        const val ACTION_UPDATE = "ACTION_UPDATE"   // 🔥 Flutter가 매초 호출
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_DISMISS = "ACTION_DISMISS"
        const val ACTION_FINISH = "ACTION_FINISH"   // 🔥 타이머 완료 알림
        const val EXTRA_SECONDS = "extra_seconds"
        const val EXTRA_MENU_NAME = "extra_menu_name"

        var currentMenuName = ""
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val seconds = intent?.getIntExtra(EXTRA_SECONDS, 0) ?: 0
        val menu = intent?.getStringExtra(EXTRA_MENU_NAME) ?: currentMenuName

        when (intent?.action) {
            ACTION_START -> {
                currentMenuName = menu
                startForeground(NOTIFICATION_ID, buildNotification(seconds, menu))
            }
            ACTION_UPDATE -> {
                // 🔥 Flutter 타이머가 매초 이걸 호출해서 알림 숫자 업데이트
                NotificationManagerCompat.from(this)
                    .notify(NOTIFICATION_ID, buildNotification(seconds, currentMenuName))
            }
            ACTION_FINISH -> {
                // 타이머 완료 → 진행 알림 제거 + 완료 알림 표시
                stopForeground(STOP_FOREGROUND_REMOVE)
                showFinishedNotification(currentMenuName)
                stopSelf()
            }
            ACTION_STOP -> {
                currentMenuName = ""
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
            ACTION_DISMISS -> {
                NotificationManagerCompat.from(this).cancel(NOTIFICATION_FINISH_ID)
            }
        }
        return START_NOT_STICKY
    }

    private fun buildNotification(seconds: Int, menuName: String): Notification {
        val min = seconds / 60
        val sec = seconds % 60
        val timeText = String.format(java.util.Locale.getDefault(), "%02d:%02d 남음", min, sec)

        val stopIntent = Intent(this, TimerForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val openIntent = Intent(this, MainActivity::class.java)
        val openPendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(menuName)
            .setContentText(timeText)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_delete, "해제", stopPendingIntent)
            .build()
    }

    private fun showFinishedNotification(menuName: String) {
        val openIntent = Intent(this, MainActivity::class.java)
        val openPendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissIntent = Intent(this, TimerForegroundService::class.java).apply {
            action = ACTION_DISMISS
        }
        val dismissPendingIntent = PendingIntent.getService(
            this, 1, dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_FINISH_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("$menuName 완료!")
            .setContentText("타이머가 종료되었습니다.")
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_delete, "해제", dismissPendingIntent)
            .build()

        NotificationManagerCompat.from(this).notify(NOTIFICATION_FINISH_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val timerChannel = NotificationChannel(
                CHANNEL_ID, "타이머", NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "타이머 진행 알림"
                setSound(null, null)
                enableVibration(false)
            }
            val finishChannel = NotificationChannel(
                CHANNEL_FINISH_ID, "타이머 완료", NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "타이머 완료 알림"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(timerChannel)
            manager.createNotificationChannel(finishChannel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
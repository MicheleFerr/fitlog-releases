package com.michele.gymbro.flutter.gymbro_flutter_new

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.util.Log

/**
 * Foreground Service for GymBro Timer
 *
 * This service keeps the timer running in the background and displays
 * a rich notification with:
 * - Real-time progress bar
 * - Quick actions (Pause/Resume/Stop)
 * - Exercise information
 * - Set tracking
 *
 * Android doesn't have Live Activities like iOS, so we use a persistent
 * foreground service with an ongoing notification that updates every second.
 */
class TimerForegroundService : Service() {

    companion object {
        private const val TAG = "TimerForegroundService"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "gymbro_timer_channel"
        private const val CHANNEL_NAME = "Workout Timer"

        // Intent actions
        const val ACTION_START = "ACTION_START_TIMER"
        const val ACTION_PAUSE = "ACTION_PAUSE_TIMER"
        const val ACTION_RESUME = "ACTION_RESUME_TIMER"
        const val ACTION_STOP = "ACTION_STOP_TIMER"
        const val ACTION_UPDATE = "ACTION_UPDATE_TIMER"

        // Intent extras
        const val EXTRA_EXERCISE_NAME = "EXTRA_EXERCISE_NAME"
        const val EXTRA_WORKOUT_NAME = "EXTRA_WORKOUT_NAME"
        const val EXTRA_REMAINING_SECONDS = "EXTRA_REMAINING_SECONDS"
        const val EXTRA_TOTAL_SECONDS = "EXTRA_TOTAL_SECONDS"
        const val EXTRA_CURRENT_SET = "EXTRA_CURRENT_SET"
        const val EXTRA_TOTAL_SETS = "EXTRA_TOTAL_SETS"
        const val EXTRA_IS_RUNNING = "EXTRA_IS_RUNNING"

        // Helper methods to start/stop service from Flutter
        fun startTimer(context: Context,
                      exerciseName: String,
                      workoutName: String?,
                      remainingSeconds: Int,
                      totalSeconds: Int,
                      currentSet: Int,
                      totalSets: Int) {
            val intent = Intent(context, TimerForegroundService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_EXERCISE_NAME, exerciseName)
                putExtra(EXTRA_WORKOUT_NAME, workoutName)
                putExtra(EXTRA_REMAINING_SECONDS, remainingSeconds)
                putExtra(EXTRA_TOTAL_SECONDS, totalSeconds)
                putExtra(EXTRA_CURRENT_SET, currentSet)
                putExtra(EXTRA_TOTAL_SETS, totalSets)
                putExtra(EXTRA_IS_RUNNING, true)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun updateTimer(context: Context,
                       remainingSeconds: Int,
                       isRunning: Boolean,
                       currentSet: Int) {
            val intent = Intent(context, TimerForegroundService::class.java).apply {
                action = ACTION_UPDATE
                putExtra(EXTRA_REMAINING_SECONDS, remainingSeconds)
                putExtra(EXTRA_IS_RUNNING, isRunning)
                putExtra(EXTRA_CURRENT_SET, currentSet)
            }
            context.startService(intent)
        }

        fun stopTimer(context: Context) {
            val intent = Intent(context, TimerForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    // Service state
    private var exerciseName: String = ""
    private var workoutName: String? = null
    private var remainingSeconds: Int = 0
    private var totalSeconds: Int = 0
    private var currentSet: Int = 1
    private var totalSets: Int = 1
    private var isRunning: Boolean = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "TimerForegroundService created")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: action=${intent?.action}")

        when (intent?.action) {
            ACTION_START -> {
                // Extract timer data
                exerciseName = intent.getStringExtra(EXTRA_EXERCISE_NAME) ?: "Exercise"
                workoutName = intent.getStringExtra(EXTRA_WORKOUT_NAME)
                remainingSeconds = intent.getIntExtra(EXTRA_REMAINING_SECONDS, 0)
                totalSeconds = intent.getIntExtra(EXTRA_TOTAL_SECONDS, 0)
                currentSet = intent.getIntExtra(EXTRA_CURRENT_SET, 1)
                totalSets = intent.getIntExtra(EXTRA_TOTAL_SETS, 1)
                isRunning = intent.getBooleanExtra(EXTRA_IS_RUNNING, false)

                // Start foreground with notification
                startForeground(NOTIFICATION_ID, buildNotification())
                Log.d(TAG, "Timer started: $exerciseName, ${formatTime(remainingSeconds)}")
            }

            ACTION_UPDATE -> {
                // Update timer state
                remainingSeconds = intent.getIntExtra(EXTRA_REMAINING_SECONDS, remainingSeconds)
                isRunning = intent.getBooleanExtra(EXTRA_IS_RUNNING, isRunning)
                currentSet = intent.getIntExtra(EXTRA_CURRENT_SET, currentSet)

                // Update notification
                updateNotification()
                Log.d(TAG, "Timer updated: ${formatTime(remainingSeconds)}, running=$isRunning")
            }

            ACTION_PAUSE -> {
                isRunning = false
                updateNotification()
                sendBroadcastToFlutter("pause")
                Log.d(TAG, "Timer paused")
            }

            ACTION_RESUME -> {
                isRunning = true
                updateNotification()
                sendBroadcastToFlutter("resume")
                Log.d(TAG, "Timer resumed")
            }

            ACTION_STOP -> {
                sendBroadcastToFlutter("stop")
                stopForeground(true)
                stopSelf()
                Log.d(TAG, "Timer stopped")
            }
        }

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW // Low importance = no sound
            ).apply {
                description = "Workout timer with progress tracking"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "Notification channel created")
        }
    }

    private fun buildNotification(): Notification {
        // Intent to open app when tapped
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        }

        // Quick action intents
        val pauseResumeIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, TimerForegroundService::class.java).apply {
                action = if (isRunning) ACTION_PAUSE else ACTION_RESUME
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val stopIntent = PendingIntent.getService(
            this,
            2,
            Intent(this, TimerForegroundService::class.java).apply {
                action = ACTION_STOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Build notification
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // TODO: Use proper icon
            .setContentTitle(buildTitle())
            .setContentText(buildSubtitle())
            .setContentIntent(openAppIntent)
            .setOngoing(true) // Cannot be dismissed
            .setOnlyAlertOnce(true) // No sound/vibration on updates
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)

        // Add progress bar (only if running)
        if (totalSeconds > 0) {
            val progress = ((totalSeconds - remainingSeconds) * 100) / totalSeconds
            builder.setProgress(100, progress, false)
        }

        // Add quick actions
        val pauseResumeLabel = if (isRunning) "⏸ Pause" else "▶ Resume"
        builder.addAction(
            android.R.drawable.ic_media_pause,
            pauseResumeLabel,
            pauseResumeIntent
        )
        builder.addAction(
            android.R.drawable.ic_delete,
            "⏹ Stop",
            stopIntent
        )

        return builder.build()
    }

    private fun updateNotification() {
        val notification = buildNotification()
        NotificationManagerCompat.from(this).notify(NOTIFICATION_ID, notification)
    }

    private fun buildTitle(): String {
        val timeStr = formatTime(remainingSeconds)
        val statusIcon = if (isRunning) "⏱" else "⏸"
        return "$statusIcon $timeStr remaining"
    }

    private fun buildSubtitle(): String {
        val setInfo = "Set $currentSet/$totalSets"
        return if (workoutName != null) {
            "$exerciseName • $setInfo • $workoutName"
        } else {
            "$exerciseName • $setInfo"
        }
    }

    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val secs = seconds % 60
        return "%d:%02d".format(minutes, secs)
    }

    private fun sendBroadcastToFlutter(action: String) {
        // Send broadcast that Flutter can listen to
        val intent = Intent("com.gymbro.TIMER_ACTION").apply {
            putExtra("action", action)
        }
        sendBroadcast(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "TimerForegroundService destroyed")
    }
}

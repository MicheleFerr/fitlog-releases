package com.michele.gymbro.flutter.gymbro_flutter_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val TIMER_CHANNEL = "com.gymbro.timer/android"
    private var timerChannel: MethodChannel? = null

    // Broadcast receiver for timer actions from service
    private val timerActionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.getStringExtra("action") ?: return
            timerChannel?.invokeMethod("onTimerAction", mapOf("action" to action))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup MethodChannel
        timerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMER_CHANNEL)
        timerChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimer" -> {
                    val exerciseName = call.argument<String>("exerciseName") ?: ""
                    val workoutName = call.argument<String>("workoutName")
                    val remainingSeconds = call.argument<Int>("remainingSeconds") ?: 0
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: 0
                    val currentSet = call.argument<Int>("currentSet") ?: 1
                    val totalSets = call.argument<Int>("totalSets") ?: 1

                    TimerForegroundService.startTimer(
                        this,
                        exerciseName,
                        workoutName,
                        remainingSeconds,
                        totalSeconds,
                        currentSet,
                        totalSets
                    )
                    result.success(true)
                }

                "updateTimer" -> {
                    val remainingSeconds = call.argument<Int>("remainingSeconds") ?: 0
                    val isRunning = call.argument<Boolean>("isRunning") ?: false
                    val currentSet = call.argument<Int>("currentSet") ?: 1

                    TimerForegroundService.updateTimer(
                        this,
                        remainingSeconds,
                        isRunning,
                        currentSet
                    )
                    result.success(true)
                }

                "stopTimer" -> {
                    TimerForegroundService.stopTimer(this)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }

        // Register broadcast receiver
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                timerActionReceiver,
                IntentFilter("com.gymbro.TIMER_ACTION"),
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(
                timerActionReceiver,
                IntentFilter("com.gymbro.TIMER_ACTION")
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(timerActionReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }
}

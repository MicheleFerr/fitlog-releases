package com.michele.gymbro.flutter.gymbro_flutter_new

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {

    private val TIMER_CHANNEL = "com.gymbro.timer/android"
    private val UNIFIED_CHANNEL = "com.gymbro.timer/unified"
    private val APP_ICON_CHANNEL = "com.gymbro/app_icon"
    private val DEFAULT_ICON = "default"
    private val PINK_ICON = "pink"
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_ICON_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(true)

                    "getCurrentIcon" -> result.success(getCurrentIcon())

                    "setIcon" -> {
                        val iconName = call.argument<String>("iconName")
                        setAppIcon(iconName)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UNIFIED_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingNotificationPayload" -> result.success(null)

                    "clearPendingNotificationPayload" -> result.success(true)

                    "getLocalTimeZone" -> result.success(TimeZone.getDefault().id)

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

    private fun getCurrentIcon(): String {
        return if (isAliasEnabled(pinkAliasComponent())) PINK_ICON else DEFAULT_ICON
    }

    private fun setAppIcon(iconName: String?) {
        val normalizedIcon = when (iconName?.trim()) {
            null, "", DEFAULT_ICON, "defaultIcon", "AppIcon" -> DEFAULT_ICON
            PINK_ICON, "AppIconPink" -> PINK_ICON
            else -> DEFAULT_ICON
        }

        val packageManager = packageManager
        val defaultState =
            if (normalizedIcon == DEFAULT_ICON) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        val pinkState =
            if (normalizedIcon == PINK_ICON) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED

        packageManager.setComponentEnabledSetting(
            defaultAliasComponent(),
            defaultState,
            PackageManager.DONT_KILL_APP
        )
        packageManager.setComponentEnabledSetting(
            pinkAliasComponent(),
            pinkState,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun isAliasEnabled(componentName: ComponentName): Boolean {
        return when (packageManager.getComponentEnabledSetting(componentName)) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> false
            else -> isComponentEnabledByManifest(componentName)
        }
    }

    private fun isComponentEnabledByManifest(componentName: ComponentName): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getActivityInfo(
                    componentName,
                    PackageManager.ComponentInfoFlags.of(0)
                ).enabled
            } else {
                @Suppress("DEPRECATION")
                packageManager.getActivityInfo(componentName, 0).enabled
            }
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun defaultAliasComponent(): ComponentName =
        ComponentName(this, "${packageName}.DefaultLauncherAlias")

    private fun pinkAliasComponent(): ComponentName =
        ComponentName(this, "${packageName}.PinkLauncherAlias")
}

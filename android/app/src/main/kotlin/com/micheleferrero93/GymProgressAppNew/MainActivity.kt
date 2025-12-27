package com.micheleferrero93.GymProgressAppNew

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * MainActivity extends FlutterFragmentActivity (not FlutterActivity) to support
 * Health Connect permissions which require the Activity Result API.
 *
 * See: https://pub.dev/packages/health#android-health-connect
 */
class MainActivity : FlutterFragmentActivity()
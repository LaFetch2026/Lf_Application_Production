package com.lafetch.customer

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    // Forward deep link intents when the app is already running.
    // With launchMode="singleTask", a new deep link tap calls onNewIntent
    // instead of onCreate. The AppsFlyer Flutter plugin handles deep links
    // automatically through the Flutter engine — no manual SDK call needed.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}

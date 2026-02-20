package com.lafetch.customer

import android.content.Intent
import android.os.Bundle
import com.appsflyer.AppsFlyerLib
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    // Forward deep link intents to AppsFlyer when the app is already running.
    // With launchMode="singleTask", a new deep link tap calls onNewIntent
    // instead of onCreate — without this, AppsFlyer never sees the link.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        AppsFlyerLib.getInstance().sendDeepLinkData(this)
    }
}

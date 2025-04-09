package com.lafetch.customer

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // No need for FacebookSdk.sdkInitialize or AppEventsLogger anymore
    }
}

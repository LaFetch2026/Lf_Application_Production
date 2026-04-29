package com.lafetch.customer

import io.flutter.app.FlutterApplication
import com.netcore.android.Smartech
import com.netcore.smartech_base.SmartechBasePlugin
import com.netcore.smartech_push.SmartechPushPlugin
import java.lang.ref.WeakReference

class MyApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // ── Netcore CE SDK native initialisation ──────────────────────────────
        Smartech.getInstance(WeakReference(applicationContext)).initializeSdk(this)
        Smartech.getInstance(WeakReference(applicationContext)).setDebugLevel(9) // remove before production
        Smartech.getInstance(WeakReference(applicationContext)).trackAppInstallUpdateBySmartech()
        SmartechBasePlugin.initializePlugin(this)
        SmartechPushPlugin.initializePlugin(this)
    }
}

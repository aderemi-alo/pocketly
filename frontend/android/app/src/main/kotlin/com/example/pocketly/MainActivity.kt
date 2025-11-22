package com.example.pocketly

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/appinfo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getVersion" -> result.success(getAppVersion())
                    "getBuildNumber" -> result.success(getAppBuildNumber())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getAppVersion(): String {
        return packageManager.getPackageInfo(packageName, 0).versionName ?: "Unknown"
    }

    private fun getAppBuildNumber(): String {
        return packageManager.getPackageInfo(packageName, 0).versionCode.toString()
    }
}

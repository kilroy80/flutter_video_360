package com.seerslab.argear.argear_flutter_plugin

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class Video360View(private val activity: Activity, context: Context, messenger: BinaryMessenger, id: Int)
    : PlatformView, MethodChannel.MethodCallHandler {

    private val TAG: String = Video360View::class.java.simpleName

    private val methodChannel: MethodChannel = MethodChannel(messenger, "kino_video_360_$id")
    lateinit var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks

    private var arGearSessionView: ARGearSessionView? = null

    init {
        methodChannel.setMethodCallHandler(this)
        arGearSessionView = ARGearSessionView(context)

        setupLifeCycle(context)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
            }
            "resume" -> {
                Log.i(TAG, "resume")
                onResume()
            }
            "pause" -> {
                Log.i(TAG, "pause")
                onPause()
            }
            "dispose" -> {
                Log.i(TAG, "dispose")
                dispose()
            }
            "exitApp" -> {
                android.os.Process.killProcess(android.os.Process.myPid())
            }
            else -> {
            }
        }
    }

    private fun setupLifeCycle(context: Context) {
        activityLifecycleCallbacks = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                Log.i(TAG, "onActivityCreated")
            }

            override fun onActivityStarted(activity: Activity) {
                Log.i(TAG, "onActivityStarted")
            }

            override fun onActivityResumed(activity: Activity) {
                Log.i(TAG, "onActivityResumed")
                onResume()
            }

            override fun onActivityPaused(activity: Activity) {
                Log.i(TAG, "onActivityPaused")
                onPause()
            }

            override fun onActivityStopped(activity: Activity) {
                Log.i(TAG, "onActivityStopped")
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
            }

            override fun onActivityDestroyed(activity: Activity) {
                Log.i(TAG, "onActivityDestroyed")
                onDestroy()
            }
        }

        activity.application.registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks)
    }
}

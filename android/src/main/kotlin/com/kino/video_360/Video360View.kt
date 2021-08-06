package com.kino.video_360

import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.kino.video_360.Video360UIView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class Video360View(private val activity: Activity, context: Context, messenger: BinaryMessenger, id: Int)
    : PlatformView, MethodChannel.MethodCallHandler {

    private val TAG: String = Video360View::class.java.simpleName

    private val methodChannel: MethodChannel = MethodChannel(messenger, "kino_video_360_$id")
    lateinit var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks

    private var videoView: Video360UIView

    init {
        methodChannel.setMethodCallHandler(this)
        videoView = Video360UIView(context)

        val layout = ViewGroup.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT
        )
        videoView.layoutParams = layout

        setupLifeCycle(context)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                val url: String? = call.argument("url")
                val isAutoPlay: Boolean? = call.argument("isAutoPlay")
                url?.let { vUrl ->
                    isAutoPlay?.let { autoPlay ->
                        videoView.initializePlayer(vUrl, autoPlay)
                    }
                }
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
            "play" -> {
                videoView.play()
            }
            "stop" -> {
                videoView.stop()
            }
            "reset" -> {
                videoView.reset()
            }
            "moveTime" -> {
                val seekTime: Double? = call.argument("moveTime")
                seekTime?.let {
                    videoView.seek(it)
                }
            }
            "duration" -> {
                result.success(videoView.getCurrentPosition())
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
                onStart()
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
                onStop()
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

    private fun onStart() {
        videoView.onStart()
    }

    private fun onResume() {
        videoView.onResume()
    }

    private fun onStop() {
        videoView.onStop()
    }

    private fun onPause() {
        videoView.onPause()
    }

    private fun onDestroy() {
        videoView.onDestroy()
    }

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {
    }
}

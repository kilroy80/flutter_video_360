package com.kino.video_360


import android.app.Activity
import android.app.Application
import android.content.Context
// import android.content.Intent
// import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
//import androidx.multidex.MultiDexApplication

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.view.TextureRegistry
//import java.util.*
// import kotlin.collections.HashMap

class Video360View(context: Context, messenger: BinaryMessenger, id: Int, textureRegistry: TextureRegistry)
    : PlatformView, MethodChannel.MethodCallHandler {

    private val TAG: String = Video360View::class.java.simpleName

    private val methodChannel: MethodChannel = MethodChannel(messenger, "kino_video_360_$id")
    lateinit var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks

    private var videoView: Video360UIView

    init {
        methodChannel.setMethodCallHandler(this)
        videoView = Video360UIView(context, textureRegistry)

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
                val isRepeat: Boolean? = call.argument("isRepeat")
                url?.let { vUrl ->
                    isAutoPlay?.let { autoPlay ->
                        isRepeat?.let { repeat ->
                            videoView.initializePlayer(vUrl, autoPlay, repeat)
//                            videoView.context.startActivity(Intent(videoView.context, VRActivity::class.java))
                        }
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
            "jumpTo" -> {
                val seekTime: Double? = call.argument("millisecond")
                seekTime?.let {
                    videoView.jumpTo(it)
                }
            }
            "seekTo" -> {
                val seekTime: Double? = call.argument("millisecond")
                seekTime?.let {
                    videoView.seekTo(it)
                }
            }
            "playing" -> {
                result.success(videoView.getPlaying())
            }
            "currentPosition" -> {
                result.success(videoView.getCurrentPosition())
            }
            "duration" -> {
                result.success(videoView.getDuration())
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

        (context.applicationContext as Application).registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks)
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
        videoView.releasePlayer()
    }
}

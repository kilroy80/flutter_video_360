package com.kino.video_360

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.ContextWrapper
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class Video360View(context: Context,
                   messenger: BinaryMessenger,
                   id: Int)
    : PlatformView, MethodChannel.MethodCallHandler {

    private val tag: String = Video360View::class.java.simpleName

    private val methodChannel: MethodChannel = MethodChannel(messenger, "kino_video_360_$id")
    private val application = context.applicationContext as Application
    private val hostActivity = context.findActivity()
    private var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks? = null
    private var isDisposed = false

    private var videoView: Video360UIView

    init {
        methodChannel.setMethodCallHandler(this)
        videoView = Video360UIView(context)

        val layout = ViewGroup.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT
        )
        videoView.layoutParams = layout

        setupLifeCycle()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (isDisposed) {
            result.error("disposed", "Video360View has already been disposed", null)
            return
        }

        when (call.method) {
            "init" -> {
                val url: String? = call.argument("url")
                val isRepeat: Boolean = call.argument("isRepeat") ?: false
                url?.let {
                    videoView.initializePlayer(it, false, isRepeat)
                }
                result.success(null)
            }
            "resume" -> {
                Log.d(tag, "resume")
                onResume()
                result.success(null)
            }
            "pause" -> {
                Log.d(tag, "pause")
                onPause()
                result.success(null)
            }
            "dispose" -> {
                Log.d(tag, "dispose")
                result.success(null)
                dispose()
            }
            "play" -> {
                videoView.play()
                result.success(null)
            }
            "stop" -> {
                videoView.stop()
                result.success(null)
            }
            "reset" -> {
                videoView.reset()
                result.success(null)
            }
            "jumpTo" -> {
                val seekTime: Double? = call.argument("millisecond")
                seekTime?.let {
                    videoView.jumpTo(it)
                }
                result.success(null)
            }
            "seekTo" -> {
                val seekTime: Double? = call.argument("millisecond")
                seekTime?.let {
                    videoView.seekTo(it)
                }
                result.success(null)
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
                result.error("unsupported", "A plugin must not terminate the host application", null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun setupLifeCycle() {
        val callbacks = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                Log.d(tag, "onActivityCreated")
            }

            override fun onActivityStarted(activity: Activity) {
                if (activity !== hostActivity) return
                Log.d(tag, "onActivityStarted")
                onStart()
            }

            override fun onActivityResumed(activity: Activity) {
                if (activity !== hostActivity) return
                Log.d(tag, "onActivityResumed")
                onResume()
            }

            override fun onActivityPaused(activity: Activity) {
                if (activity !== hostActivity) return
                Log.d(tag, "onActivityPaused")
                onPause()
            }

            override fun onActivityStopped(activity: Activity) {
                if (activity !== hostActivity) return
                Log.d(tag, "onActivityStopped")
                onStop()
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
            }

            override fun onActivityDestroyed(activity: Activity) {
                if (activity !== hostActivity) return
                Log.d(tag, "onActivityDestroyed")
                this@Video360View.dispose()
            }
        }

        activityLifecycleCallbacks = callbacks
        application.registerActivityLifecycleCallbacks(callbacks)
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

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {
        if (isDisposed) return
        isDisposed = true

        activityLifecycleCallbacks?.let(application::unregisterActivityLifecycleCallbacks)
        activityLifecycleCallbacks = null
        methodChannel.setMethodCallHandler(null)
        videoView.dispose()
    }

    private tailrec fun Context.findActivity(): Activity? = when (this) {
        is Activity -> this
        is ContextWrapper -> baseContext.findActivity()
        else -> null
    }
}

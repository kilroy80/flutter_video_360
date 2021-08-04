package com.seerslab.argear.argear_flutter_plugin

import android.app.Activity
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class Video360ViewFactory(private val activity: Activity, private val messenger: BinaryMessenger)
    : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val params = args as HashMap<*, *>
        Log.i("Video360ViewFactory", id.toString())
        Log.i("Video360ViewFactory", args.toString())
        return Video360View(activity, context, messenger, id)
    }
}

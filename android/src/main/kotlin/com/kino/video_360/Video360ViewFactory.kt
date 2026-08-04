package com.kino.video_360

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class Video360ViewFactory(private val messenger: BinaryMessenger)
    : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
//        val params = args as HashMap<*, *>
//        Log.d("Video360ViewFactory", id.toString())
//        Log.d("Video360ViewFactory", args.toString())
        requireNotNull(context) { "Context is null" }
        return Video360View(context, messenger, id)
    }
}

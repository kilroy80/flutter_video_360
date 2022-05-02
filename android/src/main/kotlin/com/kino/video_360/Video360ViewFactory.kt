package com.kino.video_360

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.view.TextureRegistry

class Video360ViewFactory(private val messenger: BinaryMessenger, private val textureRegistry: TextureRegistry)
    : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        val params = args as HashMap<*, *>
        Log.i("Video360ViewFactory", id.toString())
        Log.i("Video360ViewFactory", args.toString())
        return Video360View(context!!, messenger, id, textureRegistry)
    }
}

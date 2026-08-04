package com.kino.video_360

import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Video360Plugin */
class Video360Plugin : FlutterPlugin {

  private val tag = Video360Plugin::class.java.simpleName

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(tag, "onAttachedToEngine")

    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "kino_video_360",
      Video360ViewFactory(flutterPluginBinding.binaryMessenger)
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(tag, "onDetachedFromEngine")
  }
}

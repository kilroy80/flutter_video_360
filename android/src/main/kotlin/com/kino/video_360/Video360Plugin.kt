package com.kino.video_360

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Video360Plugin */
class Video360Plugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private val tag = Video360Plugin::class.java.simpleName
  private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(tag, "onAttachedToEngine")
    this.flutterPluginBinding = flutterPluginBinding

    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "kino_video_360",
      Video360ViewFactory(flutterPluginBinding.binaryMessenger, flutterPluginBinding.textureRegistry)
    )
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(tag, "onDetachedFromEngine")
    this.flutterPluginBinding = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(tag, "onAttachedToActivity")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(tag, "onDetachedFromActivityForConfigChanges")
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(tag, "onReattachedToActivityForConfigChanges")
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    Log.d(tag,"onDetachedFromActivity")
  }
}

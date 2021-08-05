package com.kino.video_360

import android.app.Activity
import android.content.Context;
import android.content.Intent;
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** Video360Plugin */
class Video360Plugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private val TAG = Video360Plugin::class.java.simpleName
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    companion object {
    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
              registrar.platformViewRegistry()
                      .registerViewFactory(
                          "kino_video_360", Video360ViewFactory(
                              registrar.activity(), registrar.messenger()
                          )
                      )
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    //    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kino_video_360")
    //    channel.setMethodCallHandler(this)
    //    context = flutterPluginBinding.applicationContext

        Log.i(TAG, "onAttachedToEngine")
        this.flutterPluginBinding = flutterPluginBinding
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//        if (call.method == "openPlayer") {
//            val url = call.argument<String>("url") ?: ""
//
//            val intent = Intent(context, VRActivity::class.java)
//            intent.putExtra(VRActivity.EXTRA_URL, url)
//            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            context.startActivity(intent)
//
//            result.success(null)
//        } else {
//            result.notImplemented()
//        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    //    channel.setMethodCallHandler(null)
        Log.i(TAG, "onDetachedFromEngine")
        this.flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.i(TAG, "onAttachedToActivity")
        activity = binding.activity

        flutterPluginBinding?.let {
          it.platformViewRegistry.registerViewFactory("kino_video_360",
                  Video360ViewFactory(binding.activity, it.binaryMessenger))
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "onDetachedFromActivityForConfigChanges")
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.i(TAG, "onReattachedToActivityForConfigChanges")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.i(TAG,"onDetachedFromActivity")
    }
}

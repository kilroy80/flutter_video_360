import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

typedef void Video360ControllerCallback(String method, dynamic arguments);

class Video360Controller {
  Video360Controller({
    required int id,
    this.url,
    this.width,
    this.height,
    this.onCallback,
  }) {
    _channel = MethodChannel('kino_video_360_$id');
    _channel.setMethodCallHandler(_handleMethodCalls);
    init();
  }

  late MethodChannel _channel;

  final String? url;
  final double? width;
  final double? height;
  final Video360ControllerCallback? onCallback;

  init() async {
    try {
      await _channel.invokeMethod<void>('init', {
        'url': url,
        'width': width,
        'height': height,
      });
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  play() async {
    try {
      await _channel.invokeMethod<void>('play');
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  // flutter -> android / ios callback handle
  Future<dynamic> _handleMethodCalls(MethodCall call) async {
    switch (call.method) {
      case 'play':
        break;
      default:
        print('Unknowm method ${call.method} ');
        break;
    }
    return Future.value();
  }
}

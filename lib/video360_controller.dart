import 'dart:async';
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
    this.isAutoPlay,
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
  final bool? isAutoPlay;
  final Video360ControllerCallback? onCallback;

  init() async {
    try {
      await _channel.invokeMethod<void>('init', {
        'url': url,
        'width': width,
        'isAutoPlay': isAutoPlay,
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

  stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  reset() async {
    try {
      await _channel.invokeMethod<void>('reset');
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  searchTime(double time) async {
    try {
      await _channel.invokeMethod<void>('searchTime', {
        'searchTime': time
      });
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  moveTime(double time) async {
    try {
      await _channel.invokeMethod<void>('moveTime', {
        'moveTime': time
      });
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  onPanUpdate(bool isStart, double x, double y) async {
    try {
      await _channel.invokeMethod<void>('onPanUpdate', {
        'isStart': isStart,
        'x': x,
        'y': y
      });
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  getDuration() async {
    try {
      return await _channel.invokeMethod<int>('duration');
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }


  // flutter -> android / ios callback handle
  Future<dynamic> _handleMethodCalls(MethodCall call) async {
    switch (call.method) {
      case 'play':
        break;

      case 'test':
        var duration = call.arguments['duration'];
        var total = call.arguments['total'];
        // print('$duration / $total');
        break;

      default:
        print('Unknowm method ${call.method} ');
        break;
    }
    return Future.value();
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_360_platform_interface.dart';

/// An implementation of [Video360Platform] that uses method channels.
class MethodChannelVideo360 extends Video360Platform {
  final String channelPrefix = 'kino_video_360';

  @override
  Future<void> init(int viewId, String url, double width, double height,
      bool isRepeat) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('init', {
        'url': url,
        'width': width,
        'height': height,
        'isRepeat': isRepeat,
      });
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> dispose(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('dispose');
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> play(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('play');
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> stop(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('stop');
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> reset(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('reset');
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> jumpTo(int viewId, double millisecond) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('jumpTo', {
        'millisecond': millisecond,
      });
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> seekTo(int viewId, double millisecond) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      await methodChannel.invokeMethod<void>('seekTo', {
        'millisecond': millisecond,
      });
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> onPanUpdate(int viewId, bool isStart, double x, double y) async {
    if (Platform.isIOS) {
      try {
        var methodChannel = MethodChannel('${channelPrefix}_$viewId');
        await methodChannel.invokeMethod<void>('onPanUpdate', {
          'isStart': isStart,
          'x': x,
          'y': y,
        });
      } on PlatformException catch (e) {
        debugPrint('${e.code}: ${e.message}');
      }
    }
  }

  @override
  Future<bool> isPlaying(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      return await methodChannel.invokeMethod<bool>('playing') ?? false;
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return false;
    }
  }

  @override
  Future<int> getCurrentPosition(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      return await methodChannel.invokeMethod<int>('currentPosition') ?? 0;
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return 0;
    }
  }

  @override
  Future<int> getDuration(int viewId) async {
    try {
      var methodChannel = MethodChannel('${channelPrefix}_$viewId');
      return await methodChannel.invokeMethod<int>('duration') ?? 0;
    } on PlatformException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return 0;
    }
  }
}

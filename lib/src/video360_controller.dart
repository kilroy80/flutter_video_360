import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_360/src/video360_play_info.dart';

typedef Video360ControllerCallback = void Function(
    String method, dynamic arguments);
typedef Video360ControllerPlayInfo = void Function(Video360PlayInfo playInfo);

class Video360Controller {
  Video360Controller({
    required int id,
    this.url,
    this.width,
    this.height,
    this.isAutoPlay,
    this.isRepeat,
    this.onCallback,
    this.onPlayInfo,
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
  final bool? isRepeat;
  final Video360ControllerCallback? onCallback;
  final Video360ControllerPlayInfo? onPlayInfo;

  StreamSubscription? playInfoStream;

  init() async {
    try {
      await _channel.invokeMethod<void>('init', {
        'url': url,
        'width': width,
        'isAutoPlay': isAutoPlay,
        'isRepeat': isRepeat,
        'height': height,
      });
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  dispose() async {
    try {
      playInfoStream?.cancel();
      await _channel.invokeMethod<void>('dispose');
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

  jumpTo(double millisecond) async {
    try {
      await _channel.invokeMethod<void>('jumpTo', {'millisecond': millisecond});
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  seekTo(double millisecond) async {
    try {
      await _channel.invokeMethod<void>('seekTo', {'millisecond': millisecond});
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
    }
  }

  onPanUpdate(bool isStart, double x, double y) async {
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod<void>(
            'onPanUpdate', {'isStart': isStart, 'x': x, 'y': y});
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
      }
    }
  }

  getPlaying() async {
    if (Platform.isAndroid) {
      try {
        return await _channel.invokeMethod<bool>('playing');
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
      }
    }
  }

  getCurrentPosition() async {
    if (Platform.isAndroid) {
      try {
        return await _channel.invokeMethod<int>('currentPosition');
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
      }
    }
  }

  getDuration() async {
    if (Platform.isAndroid) {
      try {
        return await _channel.invokeMethod<int>('duration');
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
      }
    }
  }

  // This function must be called only once.
  updateTime() async {
    if (Platform.isAndroid) {
      if (playInfoStream != null) {
        playInfoStream?.cancel();
        playInfoStream = null;
      }

      playInfoStream = Stream.periodic(Duration(milliseconds: 100), (x) => x)
          .listen((event) async {
        var duration = await getCurrentPosition();
        var total = await getDuration();
        var isPlaying = await getPlaying();
        onPlayInfo?.call(Video360PlayInfo(
            duration: duration, total: total, isPlaying: isPlaying));
      });
    }
  }

  // flutter -> android / ios callback handle
  Future<dynamic> _handleMethodCalls(MethodCall call) async {
    switch (call.method) {
      // for iOS updateTime
      case 'updateTime':
        var duration = call.arguments['duration'];
        var total = call.arguments['total'];
        var isPlaing = call.arguments['isPlaying'];
        onPlayInfo?.call(Video360PlayInfo(
            duration: duration, total: total, isPlaying: isPlaing));
        break;
      default:
        print('Unknowm method ${call.method} ');
        break;
    }
    return Future.value();
  }
}

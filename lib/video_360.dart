
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Video360 {
  static const MethodChannel _channel =
      const MethodChannel('kino_video_360');

  static Future<void> playVideo(String url) async {

    if (Platform.isAndroid) {
      return _channel.invokeMethod("openPlayer", <String, dynamic>{
        'url': url,
      });
    } else {

    }
  }
}

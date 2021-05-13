
import 'dart:async';

import 'package:flutter/services.dart';

class Video360 {
  static const MethodChannel _channel =
      const MethodChannel('kino_video_360');

  static Future<void> playVideo(String url) async {
    return _channel.invokeMethod("openPlayer", <String, dynamic>{
      'url': url,
    });
  }
}

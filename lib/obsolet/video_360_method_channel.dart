import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_360_platform_interface.dart';

/// An implementation of [Video360Platform] that uses method channels.
class MethodChannelVideo360 extends Video360Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_360');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

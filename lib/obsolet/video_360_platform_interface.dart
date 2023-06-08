import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_360_method_channel.dart';

abstract class Video360Platform extends PlatformInterface {
  /// Constructs a Video360Platform.
  Video360Platform() : super(token: _token);

  static final Object _token = Object();

  static Video360Platform _instance = MethodChannelVideo360();

  /// The default instance of [Video360Platform] to use.
  ///
  /// Defaults to [MethodChannelVideo360].
  static Video360Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Video360Platform] when
  /// they register themselves.
  static set instance(Video360Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

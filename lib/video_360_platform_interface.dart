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

  Future<void> init(int viewId, String url, double width, double height,
      bool isRepeat) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> dispose(int viewId) async {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<void> play(int viewId) async {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> stop(int viewId) async {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> reset(int viewId) async {
    throw UnimplementedError('reset() has not been implemented.');
  }

  Future<void> jumpTo(int viewId, double millisecond) async {
    throw UnimplementedError('jumpTo() has not been implemented.');
  }

  Future<void> seekTo(int viewId, double millisecond) async {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> onPanUpdate(int viewId, bool isStart, double x, double y) async {
    throw UnimplementedError('onPanUpdate() has not been implemented.');
  }

  Future<bool> isPlaying(int viewId) async {
    throw UnimplementedError('isPlaying() has not been implemented.');
  }

  Future<int> getCurrentPosition(int viewId) async {
    throw UnimplementedError('getCurrentPosition() has not been implemented.');
  }

  Future<int> getDuration(int viewId) async {
    throw UnimplementedError('getDuration() has not been implemented.');
  }
}

import 'dart:async';

import 'package:video_360/src/video_360_play_info.dart';
import 'package:video_360/video_360_platform_interface.dart';

typedef Video360ControllerPlayInfo = void Function(Video360PlayInfo playInfo);

class Video360Controller {
  Video360Controller({
    required this.id,
    this.url,
    this.width,
    this.height,
    this.isRepeat,
    this.onPlayInfo,
  }) {
    init(url ?? '', width ?? 0.0, height ?? 0.0, isRepeat ?? false);
  }

  final int id;
  final String? url;
  final double? width;
  final double? height;
  final bool? isRepeat;
  final Video360ControllerPlayInfo? onPlayInfo;

  StreamSubscription? playInfoStream;

  Future<void> init(
      String url, double width, double height, bool isRepeat) async {
    if (playInfoStream != null) {
      playInfoStream?.cancel();
      playInfoStream = null;
    }

    playInfoStream =
        Stream.periodic(const Duration(milliseconds: 100), (x) => x)
            .listen((event) async {
      var duration = await getCurrentPosition();
      var total = await getDuration();
      var isPlay = await isPlaying();
      onPlayInfo?.call(Video360PlayInfo(
          duration: duration, total: total, isPlaying: isPlay));
    });

    await Video360Platform.instance.init(id, url, width, height, isRepeat);
  }

  Future<void> dispose() async {
    playInfoStream?.cancel();
    await Video360Platform.instance.dispose(id);
  }

  Future<void> play() async {
    await Video360Platform.instance.play(id);
  }

  Future<void> stop() async {
    await Video360Platform.instance.stop(id);
  }

  Future<void> reset() async {
    await Video360Platform.instance.reset(id);
  }

  Future<void> jumpTo(double millisecond) async {
    await Video360Platform.instance.jumpTo(id, millisecond);
  }

  Future<void> seekTo(double millisecond) async {
    return await Video360Platform.instance.seekTo(id, millisecond);
  }

  Future<void> onPanUpdate(bool isStart, double x, double y) async {
    await Video360Platform.instance.onPanUpdate(id, isStart, x, y);
  }

  Future<bool> isPlaying() async {
    return await Video360Platform.instance.isPlaying(id);
  }

  Future<int> getCurrentPosition() async {
    return await Video360Platform.instance.getCurrentPosition(id);
  }

  Future<int> getDuration() async {
    return await Video360Platform.instance.getDuration(id);
  }
}

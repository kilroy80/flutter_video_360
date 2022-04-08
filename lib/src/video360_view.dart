import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_360/src/video360_android_view.dart';
import 'package:video_360/src/video360_controller.dart';
import 'package:video_360/src/video360_ios_view.dart';

typedef Video360ViewCreatedCallback = void Function(
    Video360Controller controller);
typedef PlatformViewCreatedCallback = void Function(int id);

class Video360View extends StatefulWidget {
  final Video360ViewCreatedCallback onVideo360ViewCreated;

  final String? url;
  final bool? isAutoPlay;
  final bool? isRepeat;
  final Video360ControllerCallback? onCallback;
  final Video360ControllerPlayInfo? onPlayInfo;

  const Video360View({
    Key? key,
    required this.onVideo360ViewCreated,
    this.url,
    this.isAutoPlay = true,
    this.isRepeat = true,
    this.onCallback,
    this.onPlayInfo,
  }) : super(key: key);

  @override
  _Video360ViewState createState() => _Video360ViewState();
}

class _Video360ViewState extends State<Video360View>
    with WidgetsBindingObserver {
  late Video360Controller controller;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        child: Video360AndroidView(
          viewType: 'kino_video_360',
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        child: GestureDetector(
          child: Video360IOSView(
            viewType: 'kino_video_360',
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
          onPanStart: (details) {
            controller.onPanUpdate(
                true, details.localPosition.dx, details.localPosition.dy);
          },
          onPanUpdate: (details) {
            controller.onPanUpdate(
                false, details.localPosition.dx, details.localPosition.dy);
          },
        ),
      );
    }
    return Center(
      child: Text(
          '$defaultTargetPlatform is not supported by the video360_view plugin'),
    );
  }

  void _onPlatformViewCreated(int id) {
    RenderBox? box = context.findRenderObject() as RenderBox?;

    var width = box?.size.width ?? 0.0;
    var heigt = box?.size.height ?? 0.0;

    controller = Video360Controller(
      id: id,
      url: widget.url,
      width: width,
      height: heigt,
      isAutoPlay: widget.isAutoPlay,
      isRepeat: widget.isRepeat,
      onCallback: widget.onCallback,
      onPlayInfo: widget.onPlayInfo,
    );
    controller.updateTime();
    widget.onVideo360ViewCreated(controller);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

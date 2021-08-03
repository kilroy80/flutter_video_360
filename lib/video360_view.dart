import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_360/video360_controller.dart';
import 'package:video_360/video360_ios_view.dart';

typedef Video360ViewCreatedCallback = void Function(Video360Controller controller);
typedef PlatformViewCreatedCallback = void Function(int id);

class Video360View extends StatefulWidget {
  final Video360ViewCreatedCallback onVideo360ViewCreated;

  final String? url;
  final Video360ControllerCallback? onCallback;

  const Video360View({
    Key? key,
    required this.onVideo360ViewCreated,
    this.url,
    this.onCallback,
  }) : super(key: key);

  @override
  _Video360ViewState createState() => _Video360ViewState();
}

class _Video360ViewState extends State<Video360View> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // return Container(
      //   child: Video360AndroidView(
      //     viewType: 'kino_video_360',
      //     onPlatformViewCreated: _onPlatformViewCreated,
      //   ),
      // );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        child: Video360IOSView(
          viewType: 'kino_video_360',
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    }
    return Center(
      child: Text(
        '$defaultTargetPlatform is not supported by the video360_view plugin'),
    );
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onVideo360ViewCreated == null) {
      return;
    }

    var pixelRatio = window.devicePixelRatio;
    RenderBox? box = context.findRenderObject() as RenderBox?;
    print(pixelRatio.toString());
    print(box?.size.toString());
    var width = box?.size.width ?? 0.0;
    var heigt = box?.size.height ?? 0.0;
    widget.onVideo360ViewCreated(Video360Controller(
      id: id,
      url: widget.url,
      width: width,
      height: heigt,
      onCallback: widget.onCallback,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

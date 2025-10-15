import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_360/src/video_360_controller.dart';
import 'package:video_360/src/view/video_360_android_view.dart';
import 'package:video_360/src/view/video_360_ios_view.dart';

typedef Video360ViewCreatedCallback = void Function(
    Video360Controller controller);

class Video360View extends StatefulWidget {
  const Video360View({
    super.key,
    required this.onVideo360ViewCreated,
    this.url,
    this.isRepeat = false,
    this.useAndroidViewSurface = true,
    this.onPlayInfo,
  });

  final Video360ViewCreatedCallback onVideo360ViewCreated;
  final String? url;
  final bool? isRepeat;
  final bool? useAndroidViewSurface;
  final Video360ControllerPlayInfo? onPlayInfo;

  @override
  State<Video360View> createState() => _Video360ViewState();
}

class _Video360ViewState extends State<Video360View>
    with WidgetsBindingObserver {
  final String viewName = 'kino_video_360';
  late Video360Controller controller;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _createAndroidView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return GestureDetector(
        child: Video360IOSView(
          viewType: viewName,
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
      );
    }
    return Center(
      child: Text(
        '$defaultTargetPlatform is not supported by the video360_view plugin',
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    RenderBox? box = context.findRenderObject() as RenderBox?;

    var width = box?.size.width ?? 0.0;
    var height = box?.size.height ?? 0.0;

    controller = Video360Controller(
      id: id,
      url: widget.url,
      width: width,
      height: height,
      isRepeat: widget.isRepeat,
      onPlayInfo: widget.onPlayInfo,
    );

    widget.onVideo360ViewCreated(controller);
  }

  Widget _createAndroidView() {
    return widget.useAndroidViewSurface == true
        ? PlatformViewLink(
            viewType: viewName,
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<
                    OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewName,
                layoutDirection: TextDirection.ltr,
                creationParams: <String, dynamic>{},
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
                ..create();
            },
          )
        : Video360AndroidView(
            viewType: viewName,
            onPlatformViewCreated: _onPlatformViewCreated,
          );
  }
}

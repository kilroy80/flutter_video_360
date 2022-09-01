import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_360/src/video360_android_view.dart';
import 'package:video_360/src/video360_controller.dart';
import 'package:video_360/src/video360_ios_view.dart';

typedef Video360ViewCreatedCallback = void Function(
    Video360Controller? controller);
typedef PlatformViewCreatedCallback = void Function(int id);

class Video360View extends StatefulWidget {
  final Video360ViewCreatedCallback onVideo360ViewCreated;

  final String? url;
  final bool? isAutoPlay;
  final bool? isRepeat;
  final bool? useAndroidViewSurface;
  final Video360ControllerCallback? onCallback;
  final Video360ControllerPlayInfo? onPlayInfo;

  const Video360View({
    Key? key,
    required this.onVideo360ViewCreated,
    this.url,
    this.isAutoPlay = true,
    this.isRepeat = true,
    this.useAndroidViewSurface = false,
    this.onCallback,
    this.onPlayInfo,
  }) : super(key: key);

  @override
  State<Video360View> createState() => _Video360ViewState();
}

class _Video360ViewState extends State<Video360View>
    with WidgetsBindingObserver {
  Video360Controller? controller;
  bool isPlatformChannel = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        isPlatformChannel = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return isPlatformChannel == true
          ? _getAndroidView()
          : Container();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        child: GestureDetector(
          child: Video360IOSView(
            viewType: 'kino_video_360',
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
          onPanStart: (details) {
            controller?.onPanUpdate(
                true, details.localPosition.dx, details.localPosition.dy);
          },
          onPanUpdate: (details) {
            controller?.onPanUpdate(
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
    controller?.updateTime();
    widget.onVideo360ViewCreated(controller!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _getAndroidView() {
    return widget.useAndroidViewSurface == true ? PlatformViewLink(
      viewType: 'kino_video_360',
      surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
          ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <
              Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        final ExpensiveAndroidViewController controller =
        PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: 'kino_video_360',
          layoutDirection: TextDirection.ltr,
          // creationParams: creationParams,
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        controller
          ..addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();

        return controller;
      },
    )
    : Video360AndroidView(
      viewType: 'kino_video_360',
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Video360IOSView extends UiKitView {
  final String viewType;
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  Video360IOSView({
    Key? key,
    required this.viewType,
    this.onPlatformViewCreated,
  }) : super(
          viewType: viewType,
          onPlatformViewCreated: onPlatformViewCreated,
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
        );
}

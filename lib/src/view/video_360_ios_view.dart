import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class Video360IOSView extends UiKitView {
  Video360IOSView({
    super.key,
    required super.viewType,
    super.onPlatformViewCreated,
  }) : super(
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
        );
}

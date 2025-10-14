import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Video360AndroidView extends AndroidView {
  Video360AndroidView({
    super.key,
    required super.viewType,
    super.onPlatformViewCreated,
  }) : super(
    creationParams: <String, dynamic>{},
    creationParamsCodec: const StandardMessageCodec(),
  );
}

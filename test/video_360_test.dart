import 'package:flutter_test/flutter_test.dart';
import 'package:video_360/video_360_platform_interface.dart';
import 'package:video_360/video_360_method_channel.dart';

void main() {
  final Video360Platform initialPlatform = Video360Platform.instance;

  test('$MethodChannelVideo360 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideo360>());
  });
}

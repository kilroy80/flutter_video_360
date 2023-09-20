import 'package:flutter_test/flutter_test.dart';
import 'package:video_360/video_360.dart';
import 'package:video_360/video_360_platform_interface.dart';
import 'package:video_360/video_360_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockVideo360Platform
//     with MockPlatformInterfaceMixin
//     implements Video360Platform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  final Video360Platform initialPlatform = Video360Platform.instance;

  test('$MethodChannelVideo360 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideo360>());
  });

  // test('getPlatformVersion', () async {
  //   Video360 video360Plugin = Video360();
  //   MockVideo360Platform fakePlatform = MockVideo360Platform();
  //   Video360Platform.instance = fakePlatform;
  //
  //   expect(await video360Plugin.getPlatformVersion(), '42');
  // });
}

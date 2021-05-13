# video_360

Simple 360 video player plugin

## Getting Started

The Android uses the open source [Google ExoPlayer](https://github.com/google/ExoPlayer)

>Google ExoPlayer Version: 2.12.1

Unfortunately, iOS will support later.

If you need all the platforms,
Uses [video_player_360](https://pub.dev/packages/video_player_360)

## Installation

Add pubspec.yaml dependencies.

``` dart
dependencies:
  video_360: ^0.0.1
```

Add AndroidManifest.xml

``` kotlin
<activity
    android:name="com.kino.video_360.VRActivity"
    android:theme="@style/NormalTheme"
    android:launchMode="singleTask"
    android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation|layoutDirection"
    android:imeOptions="flagNoExtractUi|flagNoFullscreen"
    android:windowSoftInputMode="adjustNothing|stateHidden" />
```
## How to use

importing the libray:
``` dart
import 'package:video_360/video_360.dart';
```

play video:
``` dart
Video360.playVideo("360_VIDEO_URL_HERE");
```

samepl code:
``` dart
import 'package:flutter/material.dart';

import 'package:video_360/video_360.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video 360 example app'),
        ),
        body: Center(
          child: MaterialButton(
             onPressed: () =>
                Video360.playVideo(
                  'your video url'
                ),
             color: Colors.grey[100],
             child: Text('Play Video'),
           ),
         ),
      ),
    );
  }
}
```

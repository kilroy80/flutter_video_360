# video_360

Simple 360 video player plugin
(Android, iOS support)

## Getting Started

The Android uses the open source [Google ExoPlayer](https://github.com/google/ExoPlayer)

> Google ExoPlayer Version: 2.17.1

The iOS users the open source [Swifty360Player](https://github.com/abdullahselek/Swifty360Player)

> Swifty360Player Version: 0.2.5

## Installation

Add pubspec.yaml dependencies.

```dart
dependencies:
  video_360: ^0.0.4
```

Android Requirements

> Minimum SDK Target : 24

iOS Requirements

> Minimum iOS Target : 11.0
> Swift Version : 5.x

## How to use

importing the libray:

```dart
import 'package:video_360/video_360.dart';
```

Add Video360View:

```dart
Video360View(
    onVideo360ViewCreated: _onVideo360ViewCreated,
    url: YOUR_360_VIDEO_URL,
    isAutoPlay: true,   // defalut : true
    isRepeat: true, // defalut : true
    onPlayInfo: (Video360PlayInfo info) {
        // Play info Callback
    },
)
```

Video360Controller Method

> play() : video play
> stop() : video stop
> reset() : video reset
> jumpTo() : video jump, parameter is milesecond
> seekTo() : video seek, parameter is plus, minus milesecond

sample code:

```dart
import 'package:flutter/material.dart';
import 'package:video_360/video_360.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Video360Controller controller;

  String durationText = '';
  String totalText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video 360 Plugin example app'),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Video360View(
                onVideo360ViewCreated: _onVideo360ViewCreated,
                url:
                    'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8',
                onPlayInfo: (Video360PlayInfo info) {
                  setState(() {
                    durationText = info.duration.toString();
                    totalText = info.total.toString();
                  });
                },
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      controller.play();
                    },
                    color: Colors.grey[100],
                    child: const Text('Play'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      controller.stop();
                    },
                    color: Colors.grey[100],
                    child: const Text('Stop'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      controller.reset();
                    },
                    color: Colors.grey[100],
                    child: const Text('Reset'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      controller.jumpTo(80000);
                    },
                    color: Colors.grey[100],
                    child: const Text('1:20'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      controller.seekTo(-2000);
                    },
                    color: Colors.grey[100],
                    child: const Text('<<'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      controller.seekTo(2000);
                    },
                    color: Colors.grey[100],
                    child: const Text('>>'),
                  ),
                  Flexible(
                    child: MaterialButton(
                      onPressed: () {},
                      color: Colors.grey[100],
                      child: Text(durationText + ' / ' + totalText),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _onVideo360ViewCreated(Video360Controller controller) {
    this.controller = controller;
  }
}
```

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_360/video360_controller.dart';
import 'package:video_360/video360_view.dart';

import 'package:video_360/video_360.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Video360Controller controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Platform.isAndroid? Center(
          child: MaterialButton(
             onPressed: () =>
                Video360.playVideo(
                  'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8'
                ),
             color: Colors.grey[100],
             child: Text('Play Video'),
           ),
         ) : Stack(
          children: [
            Center(
              child: Container(
                width: 320,
                height: 500,
                child: Video360View(
                  onVideo360ViewCreated: _onVideo360ViewCreated,
                  url: 'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8',
                ),
              ),
            ),
            Column(
              children: [
                MaterialButton(
                  onPressed: () {
                    controller.play();
                  },
                  color: Colors.grey[100],
                  child: Text('Play Video'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _onVideo360ViewCreated(Video360Controller controller) {
    this.controller = controller;
  }
}

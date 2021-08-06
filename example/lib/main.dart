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
  var preX = -1.0;
  var preY = -1.0;

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
        body: Stack(
          children: [
            Center(
              child: GestureDetector(
                child: Container(
                  width: 320,
                  height: 500,
                  child: Video360View(
                    onVideo360ViewCreated: _onVideo360ViewCreated,
                    url: 'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8',
                  ),
                ),
                onPanStart: (details) {
                  controller.onPanUpdate(true, details.localPosition.dx, details.localPosition.dy);
                },
                onPanUpdate: (details) {
                  controller.onPanUpdate(false, details.localPosition.dx, details.localPosition.dy);
                },
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
                      child: Text('Play'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        controller.stop();
                      },
                      color: Colors.grey[100],
                      child: Text('Stop'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        controller.reset();
                      },
                      color: Colors.grey[100],
                      child: Text('Reset'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        controller.searchTime(80);
                      },
                      color: Colors.grey[100],
                      child: Text('1:20'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        controller.moveTime(-20);
                      },
                      color: Colors.grey[100],
                      child: Text('<<'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        controller.moveTime(20);
                      },
                      color: Colors.grey[100],
                      child: Text('>>'),
                    ),
                    Flexible(
                      child: Center(
                        child: Text("00:00"
                        ),
                      ),
                    ),
                    // Flexible(child: child),
                    MaterialButton(
                      onPressed: () {
                        controller.searchTime(80);
                      },
                      color: Colors.grey[100],
                      child: Text('--'),
                    ),
                  ],
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

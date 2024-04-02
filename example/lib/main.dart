import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ve_game_view/ve_game_view.dart';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final completer = Completer<VeGameViewController>();

  void _initAndStart() async {
    await VeGameInitializer.init(accountId);
    final gameViewController = await completer.future;
    final result = await gameViewController.start(
      VeGameConfig(
        ak: ak,
        sk: sk,
        token: token,
        gameId: gameId,
        uid: "ytbhf87768",
        reservedId: "7352865170319809299",
        sessionMode: 2,
        keyBoardEnable: false,
      ),
    );
    print("start $result}");
  }

  @override
  void initState() {
    super.initState();
    _initAndStart();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VeGameView(
              onCreated: (controller) {
                if (completer.isCompleted) {
                  return;
                }
                completer.complete(controller);
              },
            ),
          ),
        ),
      ),
    );
  }
}

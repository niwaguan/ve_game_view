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
  late VeGameViewController gameViewController;

  void _initAndStart() {
    VeGameInitializer.init(accountId);
  }

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
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VeGameView(
              onCreated: (controller) {
                gameViewController = controller;
                controller.start(
                  VeGameConfig(
                    uid: uid,
                    ak: ak,
                    sk: sk,
                    token: token,
                    gameId: gameId,
                    reservedId: "7352865170319809299",
                    sessionMode: 2,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 've_game_view_platform_interface.dart';

/// An implementation of [VeGameViewPlatform] that uses method channels.
class MethodChannelVeGameView extends VeGameViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ve_game_view');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

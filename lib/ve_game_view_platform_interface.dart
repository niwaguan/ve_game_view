import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 've_game_view_method_channel.dart';

abstract class VeGameViewPlatform extends PlatformInterface {
  /// Constructs a VeGameViewPlatform.
  VeGameViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static VeGameViewPlatform _instance = MethodChannelVeGameView();

  /// The default instance of [VeGameViewPlatform] to use.
  ///
  /// Defaults to [MethodChannelVeGameView].
  static VeGameViewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VeGameViewPlatform] when
  /// they register themselves.
  static set instance(VeGameViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

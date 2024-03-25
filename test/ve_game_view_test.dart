import 'package:flutter_test/flutter_test.dart';
import 'package:ve_game_view/ve_game_view.dart';
import 'package:ve_game_view/ve_game_view_platform_interface.dart';
import 'package:ve_game_view/ve_game_view_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVeGameViewPlatform
    with MockPlatformInterfaceMixin
    implements VeGameViewPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VeGameViewPlatform initialPlatform = VeGameViewPlatform.instance;

  test('$MethodChannelVeGameView is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVeGameView>());
  });

  test('getPlatformVersion', () async {
    VeGameView veGameViewPlugin = VeGameView();
    MockVeGameViewPlatform fakePlatform = MockVeGameViewPlatform();
    VeGameViewPlatform.instance = fakePlatform;

    expect(await veGameViewPlugin.getPlatformVersion(), '42');
  });
}

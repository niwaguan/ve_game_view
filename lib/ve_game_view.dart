
import 've_game_view_platform_interface.dart';

class VeGameView {
  Future<String?> getPlatformVersion() {
    return VeGameViewPlatform.instance.getPlatformVersion();
  }
}

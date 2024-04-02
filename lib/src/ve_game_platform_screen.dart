import 'model/ve_game_config.dart';
import 've_game_method_channel.dart';

class VeGamePlatformScreen {
  /// 启动原生平台视图以开始游戏
  /// Android - 原生Activity
  /// iOS - 原生Controller
  static start(VeGameConfig config) {
    VeGameMethodChannel().invokeMethod("start", config.toJson());
  }
}

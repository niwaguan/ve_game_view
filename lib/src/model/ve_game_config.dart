part of ve_game_view;

/// 启动游戏的配置
class VeGameConfig {
  /// 用户id
  final String uid;

  /// 接入key
  final String ak;

  /// 接入sk
  final String sk;

  /// 临时token
  final String token;

  /// 启动的游戏id
  final VeGame gameId;

  VeGameConfig({
    required this.uid,
    required this.ak,
    required this.sk,
    required this.token,
    required this.gameId,
  });

  Object toJson() {
    return {
      "uid": uid,
      "ak": ak,
      "sk": sk,
      "token": token,
      "gameId": gameId,
    };
  }
}

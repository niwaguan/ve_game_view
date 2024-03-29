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

  /// 启动的游戏id。需要提前在管理控制台创建游戏后获取
  final String gameId;

  /// 回合id。若未指定，使用 uid+[1,2,3,...]
  final String? roundId;

  VeGameConfig({
    required this.uid,
    required this.ak,
    required this.sk,
    required this.token,
    required this.gameId,
    this.roundId,
  });

  Object toJson() {
    final r = {
      "uid": uid,
      "ak": ak,
      "sk": sk,
      "token": token,
      "gameId": gameId,
    };
    if (roundId?.isNotEmpty == true) {
      r["roundId"] = roundId!;
    }
    return r;
  }
}

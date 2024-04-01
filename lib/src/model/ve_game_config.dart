/// 启动游戏的配置
class VeGameConfig {
  /// 唯一用户身份标识，由业务方自定义，用于标识用户在游戏房间中的身份，在用户重连时需保持 userId 不变
  /// （此 userId 与调用服务端 PreAllocateResource 接口时指定的 client_user_id 相同）
  final String uid;

  /// 接入key
  final String ak;

  /// 接入sk
  final String sk;

  /// 用于用户鉴权的临时 Token，需通过调用服务端 STSToken接口 获取
  final String token;

  /// 待启动的游戏 ID，通过火山引擎云游戏控制台 游戏管理 页面获取
  final String gameId;

  /// 当次游戏生命周期的标识符，可以使用该参数查询游戏使用时长。若未指定，使用 uid+[1,2,3,...]
  final String? roundId;

  /// 传输的流类型。1 只传输音频；2 只传输视频；3 两者一起，默认值；
  final int streamType;

  /// 资源预锁定 ID，通过调用服务端 PreAllocateResource 接口获取（如不传入，将在开始播放成功回调中返回）
  final String? reservedId;

  /// 启动游戏模式：
  /// 0（普通模式，默认）
  /// 1（挂机模式）
  /// 2（仅退出客户端，不退出服务端）
  /// 说明：当开启多人游戏时，仅操作者可以设置挂机模式
  final int sessionMode;

  final Map<String, Object>? extra;

  VeGameConfig({
    required this.uid,
    required this.ak,
    required this.sk,
    required this.token,
    required this.gameId,
    this.roundId,
    this.reservedId,
    this.extra,
    this.streamType = 3,
    this.sessionMode = 0,
  });

  Object toJson() {
    final r = {
      "uid": uid,
      "ak": ak,
      "sk": sk,
      "token": token,
      "gameId": gameId,
      "streamType": streamType,
      "sessionMode": sessionMode,
    };
    if (roundId?.isNotEmpty == true) {
      r["roundId"] = roundId!;
    }
    if (reservedId?.isNotEmpty == true) {
      r['reservedId'] = reservedId!;
    }
    if (extra?.isNotEmpty == true) {
      r["extra"] = extra!;
    }
    return r;
  }
}

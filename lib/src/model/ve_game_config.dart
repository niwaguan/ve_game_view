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
  final String? gameId;

  /// 注册游戏时指定的用户自定义游戏 ID。[gameId]优先级更高。为空时，必须传递[gameId]
  final String? customGameId;

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

  /// 启动游戏的场景，用于控制是否开启多人游戏及游戏控制权转移：
  /// 0（单用户，默认）
  /// 1（单房间多用户，不可转移游戏控制权）
  /// 2（单房间多用户, 可转移游戏控制权）
  final int roomType;

  /// 当前用户进入游戏的默认角色，可选项：
  /// 0：观看者，默认
  /// 1：操作者
  /// 说明：指定 roomType 和该参数后，可在游戏中调用 changeRole 接口将观看者设置为操作者，转移游戏控制权。进入游戏的观看者也会占用实例资源，建议控制观看者数量。
  final int role;

  /// 火山侧套餐 ID，可通过调用服务端 ListResourceSet 接口获取（configuration_code 字段）
  final String? planId;

  /// 是否允许用户使用键盘进行信息输入，默认：YES
  final bool keyBoardEnable;

  /// 游戏视频流清晰度 ID；如不传入，则使用默认清晰度
  /// 注意：如果启动游戏时使用的资源套餐为 “基础型”，视频流清晰度档位将默认设置为 “1”（720P，4000kbps，30FPS）
  /// 清晰度参考：https://bytedance.feishu.cn/docx/doxcnoH9h2a9tSJdJLRSzBiKFFh
  final int? videoStreamProfileId;

  /// 设置无操作自动回收服务时长，单位秒（如不设置或设置为0，则使用默认时长300秒，支持设置的上限值为7200，即2小时）
  final int? autoRecycleTime;

  /// 保存用户游戏配置文件的路径列表（如需在游戏进行中通过 setUserProfilePath 接口设置保存配置文件的路径，需要配置该参数）
  final List<String>? userProfilePath;

  /// 设置游戏玩家排队功能：
  /// 0：不设置排队功能
  /// 1~99：队列优先级，数值越小优先级越高
  final int? queuePriority;

  /// 根据业务需要，自定义的扩展参数；详细信息，
  /// 参考: https://bytedance.feishu.cn/docx/Q2Ofd7JTbos1KLxubETcbfsBnEe
  final Map<String, String>? extra;

  VeGameConfig({
    required this.uid,
    required this.ak,
    required this.sk,
    required this.token,
    required this.gameId,
    this.customGameId,
    this.roundId,
    this.reservedId,
    this.planId,
    this.extra,
    this.videoStreamProfileId,
    this.autoRecycleTime,
    this.userProfilePath,
    this.queuePriority,
    this.streamType = 3,
    this.sessionMode = 0,
    this.roomType = 0,
    this.role = 0,
    this.keyBoardEnable = true,
  });

  Object toJson() {
    final r = {
      "uid": uid,
      "ak": ak,
      "sk": sk,
      "token": token,
      "streamType": streamType,
      "sessionMode": sessionMode,
      "roomType": roomType,
      "role": role,
      "keyBoardEnable": keyBoardEnable,
    };
    if (gameId != null) {
      r["gameId"] = gameId!;
    }
    if (customGameId != null) {
      r["customGameId"] = customGameId!;
    }
    if (roundId?.isNotEmpty == true) {
      r["roundId"] = roundId!;
    }
    if (reservedId?.isNotEmpty == true) {
      r['reservedId'] = reservedId!;
    }
    if (planId?.isNotEmpty == true) {
      r["planId"] = planId!;
    }
    if (extra?.isNotEmpty == true) {
      r["extra"] = extra!;
    }
    if (videoStreamProfileId != null) {
      r['videoStreamProfileId'] = videoStreamProfileId!;
    }
    if (autoRecycleTime != null) {
      r['autoRecycleTime'] = autoRecycleTime!;
    }
    if (userProfilePath?.isNotEmpty == true) {
      r['userProfilePath'] = userProfilePath!;
    }
    if (queuePriority != null) {
      r['queuePriority'] = queuePriority!;
    }
    return r;
  }
}

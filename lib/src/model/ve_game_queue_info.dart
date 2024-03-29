class QueueInfo {
  /// 资源套餐信息
  final String configurationCode;

  /// 当前用户所处队列中的位置
  final int userPosition;

  /// 队列总长度
  final int total;

  QueueInfo(
      {required this.configurationCode,
      required this.userPosition,
      required this.total});

  QueueInfo.fromJson(Map<String, Object> obj)
      : configurationCode = obj["configurationCode"] as String,
        userPosition = obj["userPosition"] as int,
        total = obj["total"] as int;
}

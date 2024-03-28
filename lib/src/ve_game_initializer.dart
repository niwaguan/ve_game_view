part of ve_game_view;

class VeGameInitializer {
  /// 初始化sdk
  /// [accountId] 申请VeGameSDK中的accountId
  /// 注意：Android的accountId还需在 <project>/android/app/src/main/AndroidManifest.xml中配置。
  /// 参考 https://github.com/volcengine/veGame/tree/master/QuickStart/Android
  static Future<void> init(String accountId) {
    return VeGameMethodChannel()
        .invokeMethod<void>("init", {"accountId": accountId});
  }
}

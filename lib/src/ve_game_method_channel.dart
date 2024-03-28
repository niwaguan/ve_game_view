part of ve_game_view;

/// 插件级别的MethodChannel
class VeGameMethodChannel {
  VeGameMethodChannel._();

  static final VeGameMethodChannel _instance = VeGameMethodChannel._();

  final _methodChannel = const MethodChannel(viewTypeId);

  factory VeGameMethodChannel() => _instance;

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return _methodChannel.invokeMethod(method, arguments);
  }
}

part of ve_game_view;

class VeGameViewController {
  final MethodChannel _channel;

  VeGameViewController._(int id) : _channel = MethodChannel('$viewTypeId.$id') {
    _channel.setMethodCallHandler((call) async {
      return null;
    });
  }
}

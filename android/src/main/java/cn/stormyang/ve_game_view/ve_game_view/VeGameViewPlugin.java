package cn.stormyang.ve_game_view.ve_game_view;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

/** VeGameViewPlugin */
public class VeGameViewPlugin implements FlutterPlugin {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    binding.getPlatformViewRegistry().registerViewFactory(Constants.GAME_TYPE_ID, new VeGameViewFactory(binding.getBinaryMessenger()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}

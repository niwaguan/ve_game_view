package cn.stormyang.ve_game_view.ve_game_view;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.volcengine.cloudgame.VeGameEngine;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

/** VeGameViewPlugin */
public class VeGameViewPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  @Nullable
  private MethodChannel channel;
  @Nullable
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), Constants.GAME_TYPE_ID);
    channel.setMethodCallHandler(this);
    binding.getPlatformViewRegistry().registerViewFactory(Constants.GAME_TYPE_ID, new VeGameViewFactory(binding.getBinaryMessenger()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
      assert channel != null;
      channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if ("init".equals(call.method) && context != null) {
      VeGameEngine.getInstance().prepare(context);
    }
  }
}

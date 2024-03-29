package cn.stormyang.ve_game_view.ve_game_view;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.volcengine.cloudgame.VeGameEngine;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

/** VeGameViewPlugin */
public class VeGameViewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  @Nullable
  private MethodChannel channel;
  @Nullable
  private Context context;

  private VeGameViewFactory viewFactory;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), Constants.GAME_TYPE_ID);
    channel.setMethodCallHandler(this);
    viewFactory = new VeGameViewFactory(binding.getBinaryMessenger());
    binding.getPlatformViewRegistry().registerViewFactory(Constants.GAME_TYPE_ID, viewFactory);
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

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    if (viewFactory != null) {
      viewFactory.setActivity(binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    if (viewFactory != null) {
      viewFactory.setActivity(null);
    }
  }
}

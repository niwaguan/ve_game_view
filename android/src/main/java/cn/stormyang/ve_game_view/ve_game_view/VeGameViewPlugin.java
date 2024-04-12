package cn.stormyang.ve_game_view.ve_game_view;

import static androidx.core.content.ContextCompat.startActivity;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.volcengine.cloudcore.common.mode.Role;
import com.volcengine.cloudcore.common.mode.StreamType;
import com.volcengine.cloudgame.GamePlayConfig;
import com.volcengine.cloudgame.VeGameEngine;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;
import java.util.Map;

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

  private ActivityPluginBinding activityPluginBinding;

  private int roundId = 0;

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
    if ("init".equals(call.method)) {
      if (context != null) {
        VeGameEngine.setDebug(true);
        VeGameEngine.getInstance().prepare(context);
        result.success(null);
        return;
      }
      result.error("-1", "Flutter not ready", null);
    } else if ("start".equals(call.method)) {
      if (!(call.arguments instanceof Map)) {
        result.error("1", "Arguments Type Error.", "This method require a argument of Map, but you give a " + call.arguments.getClass());
        return;
      }

      String uid = call.argument("uid");
      if (uid == null || uid.isEmpty()) {
        result.error("2", "'uid' is absent", null);
        return;
      }
      String ak = call.argument("ak");
      if (ak == null || ak.isEmpty()) {
        result.error("2", "'ak' is absent", null);
        return;
      }
      String sk = call.argument("sk");
      if (sk == null || sk.isEmpty()) {
        result.error("2", "'sk' is absent", null);
        return;
      }
      String token = call.argument("token");
      if (token == null || token.isEmpty()) {
        result.error("2", "'token' is absent", null);
        return;
      }

      String gameId = call.argument("gameId");
      String customGameId = call.argument("customGameId");
      if ((gameId == null || gameId.isEmpty()) && (customGameId == null || customGameId.isEmpty())) {
        result.error("2", "'gameId' or 'customGameId' is absent", null);
        return;
      }

      Intent intent = new Intent(activityPluginBinding.getActivity(), VeGameInspectActivity.class);
      intent.putExtra("uid", uid);
      intent.putExtra("ak", ak);
      intent.putExtra("sk", sk);
      intent.putExtra("token", token);
      if (gameId != null) {
        intent.putExtra("gameId", gameId);
      }
      if (customGameId != null) {
        intent.putExtra("customGameId", customGameId);
      }

      String roundId = call.argument("roundId");
      if (roundId == null) {
        roundId = uid + (++this.roundId);
      }
      intent.putExtra("roundId", roundId);

      Integer streamType = call.argument("streamType");
      if (streamType != null) {
        intent.putExtra("streamType",streamType);
      }
      String reservedId = call.argument("reservedId");
      if (reservedId != null) {
        intent.putExtra("reservedId", reservedId);
      }
      Integer sessionMode = call.argument("sessionMode");
      if (sessionMode != null) {
        intent.putExtra("sessionMode", sessionMode);
      }
      Integer roomType = call.argument("roomType");
      if (roomType != null) {
        intent.putExtra("roomType", roomType);
      }
      Integer role = call.argument("role");
      if (role != null) {
        intent.putExtra("role", role);
      }
      String planId = call.argument("planId");
      if (planId != null) {
        intent.putExtra("planId", planId);
      }
      Boolean keyBoardEnable = call.argument("keyBoardEnable");
      intent.putExtra("keyBoardEnable", keyBoardEnable);

      Integer videoStreamProfileId = call.argument("videoStreamProfileId");
      if (videoStreamProfileId != null) {
        intent.putExtra("videoStreamProfileId", videoStreamProfileId);
      }
      Integer autoRecycleTime = call.argument("autoRecycleTime");
      if (autoRecycleTime != null) {
        intent.putExtra("autoRecycleTime", autoRecycleTime);
      }
      List<String> userProfilePath = call.argument("userProfilePath");
      if (userProfilePath != null) {
        intent.putExtra("userProfilePath", new JSONArray(userProfilePath).toString());
      }
      Integer queuePriority = call.argument("queuePriority");
      if (queuePriority != null) {
        intent.putExtra("queuePriority", queuePriority);
      }
      Map<String, String> extra = call.argument("extra");
      if (extra != null) {
        intent.putExtra("extra", new JSONObject(extra).toString());
      }

      startActivity(activityPluginBinding.getActivity(), intent, null);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activityPluginBinding = binding;
    if (viewFactory != null) {
      viewFactory.setActivity(binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activityPluginBinding = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activityPluginBinding = binding;
  }

  @Override
  public void onDetachedFromActivity() {
    activityPluginBinding = null;
    if (viewFactory != null) {
      viewFactory.setActivity(null);
    }
  }
}

package cn.stormyang.ve_game_view.ve_game_view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.volcengine.androidcloud.common.model.StreamStats;
import com.volcengine.cloudcore.common.mode.LocalStreamStats;
import com.volcengine.cloudcore.common.mode.QueueInfo;
import com.volcengine.cloudcore.common.mode.StreamType;
import com.volcengine.cloudgame.GamePlayConfig;
import com.volcengine.cloudgame.VeGameEngine;
import com.volcengine.cloudphone.apiservice.outinterface.IGamePlayerListener;
import com.volcengine.cloudphone.apiservice.outinterface.IStreamListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.platform.PlatformView;

public class VeGameView implements PlatformView, MethodCallHandler, IGamePlayerListener, IStreamListener {
    private final String TAG = "VeGameView";
    @NonNull
    private final FrameLayout mContainer;

    @NonNull
    private final MethodChannel methodChannel;

    private Integer roundId = 0;

    VeGameView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, @NonNull BinaryMessenger binaryMessenger, Activity activity) {
        mContainer = new FrameLayout(activity);
        mContainer.setLayoutParams(new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
        ));
        mContainer.setVisibility(View.VISIBLE);
        mContainer.setBackgroundColor(Color.rgb(213, 0, 0));

        methodChannel = new MethodChannel(binaryMessenger, Constants.GAME_TYPE_ID + "." + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        return mContainer;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        VeGameEngine.getInstance().stop();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if("start".equals(call.method)) {
            onStartMethodCall(call, result);
        } else if ("stop".equals(call.method)) {
            onStopMethodCall(call, result);
        }
    }

    void onStartMethodCall(@NonNull MethodCall call, @NonNull Result result) {
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
            result.error("3", "'ak' is absent", null);
            return;
        }
        String sk = call.argument("sk");
        if (sk == null || sk.isEmpty()) {
            result.error("4", "'sk' is absent", null);
            return;
        }
        String token = call.argument("token");
        if (token == null || token.isEmpty()) {
            result.error("5", "'token' is absent", null);
            return;
        }
        String gameId = call.argument("gameId");
        if (gameId == null || gameId.isEmpty()) {
            result.error("6", "'gameId' is absent", null);
            return;
        }
        String roundId = call.argument("roundId");
        if (roundId == null) {
            roundId = uid + (++this.roundId);
        }

        GamePlayConfig.Builder builder = new GamePlayConfig.Builder();
        builder.userId(uid).ak(ak).sk(sk).token(token).gameId(gameId)
                .container(mContainer).roundId(roundId).streamListener(this);

        Integer streamType = call.argument("streamType");
        if (streamType != null) {
            builder.streamType(StreamType.valueOf(streamType));
        }
        String reservedId = call.argument("reservedId");
        if (reservedId != null) {
            builder.reservedId(reservedId);
        }

        GamePlayConfig mGamePlayConfig = builder.build();
        VeGameEngine.getInstance().start(mGamePlayConfig, this);
        result.success(null);
    }
    void onStopMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        VeGameEngine.getInstance().stop();
    }

    @Override
    public void onPlaySuccess(String s, int i, Map<String, String> map, String s1, String s2) {
        Log.i(TAG, "onPlaySuccess");
        methodChannel.invokeMethod("onPlaySuccess", new HashMap<String, Object>(){{
            put("roundId", s);
            put("videoStreamProfileId", i);
            put("extra", map);
            put("gameId", s1);
            put("reservedId", s2);
        }});
    }

    @Override
    public void onError(int i, String s) {
        Log.i(TAG, "onError, i:" + i + ", s: " + s);
        VeGameEngine.getInstance().stop();
        methodChannel.invokeMethod("onError", new HashMap<String, Object>(){{
            put("code", i);
            put("message", s);
        }});
    }

    @Override
    public void onWarning(int i, String s) {
        Log.i(TAG, "onWarning, i:" + i + ", s: " + s);
        methodChannel.invokeMethod("onWarning", new HashMap<String, Object>(){{
            put("code", i);
            put("message", s);
        }});
    }

    @Override
    public void onNetworkChanged(int i) {
        Log.i(TAG, "onWarning, i:" + i);
        methodChannel.invokeMethod("onNetworkChanged", new HashMap<String, Integer>(){{
            put("type", i);
        }});
    }

    @Override
    public void onServiceInit() {
        Log.i(TAG, "onServiceInit");
        methodChannel.invokeMethod("onServiceInit", null);
    }

    @Override
    public void onQueueUpdate(List<QueueInfo> list) {
        Log.i(TAG, "onQueueUpdate");
        /// 将list中的元素转换为hashmap
        List<HashMap<String, Object>> queueInfoList = new ArrayList<>();
        for (QueueInfo queueInfo : list) {
            HashMap<String, Object> queueInfoMap = new HashMap<>();
            queueInfoMap.put("total", queueInfo.total);
            queueInfoMap.put("userPosition", queueInfo.userPosition);
            queueInfoMap.put("configurationCode", queueInfo.configurationCode);
            queueInfoList.add(queueInfoMap);
        }
        methodChannel.invokeMethod("onQueueUpdate", queueInfoList);
    }

    @Override
    public void onQueueSuccessAndStart(int i) {
        Log.i(TAG, "onQueueSuccessAndStart");
        methodChannel.invokeMethod("onQueueSuccessAndStart", new HashMap<String, Integer>(){{
            put("remainTime", i);
        }});
    }

    @Override
    public void onFirstAudioFrame(String s) {

    }

    @Override
    public void onFirstRemoteVideoFrame(String s) {

    }

    @Override
    public void onStreamStarted() {

    }

    @Override
    public void onStreamPaused() {

    }

    @Override
    public void onStreamResumed() {

    }

    @Override
    public void onStreamStats(StreamStats streamStats) {

    }

    @Override
    public void onLocalStreamStats(LocalStreamStats localStreamStats) {

    }

    @Override
    public void onStreamConnectionStateChanged(int i) {

    }

    @Override
    public void onDetectDelay(long l) {

    }

    @Override
    public void onRotation(int i) {

    }

    @Override
    public void onPodExit(int i, String s) {

    }

    @Override
    public void onNetworkQuality(int i) {

    }
}

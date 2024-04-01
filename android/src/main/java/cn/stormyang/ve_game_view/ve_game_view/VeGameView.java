package cn.stormyang.ve_game_view.ve_game_view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.volcengine.androidcloud.common.model.StreamStats;
import com.volcengine.cloudcore.common.mode.KeySateType;
import com.volcengine.cloudcore.common.mode.LocalStreamStats;
import com.volcengine.cloudcore.common.mode.MouseKey;
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
import java.util.Objects;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
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
                FrameLayout.LayoutParams.WRAP_CONTENT
        ));
        mContainer.setBackgroundColor(Color.rgb(255,0,0));
        mContainer.setVisibility(View.VISIBLE);

        // test
//        TextView textView = new TextView(activity);
//        mContainer.addView(textView);
//        textView.setLayoutParams(new FrameLayout.LayoutParams(
//                FrameLayout.LayoutParams.MATCH_PARENT,
//                FrameLayout.LayoutParams.WRAP_CONTENT
//        ));
//        textView.setTextSize(20);
//        textView.setBackgroundColor(Color.rgb(0, 0, 255));
//        textView.setText("Rendered on a native Android view (id: " + id + ")");

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
        } else if ("sendMouseMovement".equals(call.method)) {
            onMouseMovementCall(call, result);
        } else if ("sendMousePosition".equals(call.method)) {
            onMousePositionCall(call, result);
        } else if("sendMouseKeyChanged".equals(call.method)) {
            onMouseKeyChanged(call, result);
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
        if (gameId == null || gameId.isEmpty()) {
            result.error("2", "'gameId' is absent", null);
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
        Integer sessionMode = call.argument("sessionMode");
        if (sessionMode != null) {
            builder.sessionMode(sessionMode);
        }

        GamePlayConfig mGamePlayConfig = builder.build();
        VeGameEngine.getInstance().start(mGamePlayConfig, this);
        result.success(null);
    }
    void onStopMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        VeGameEngine.getInstance().stop();
    }

    void onMouseKeyChanged(@NonNull MethodCall call, @NonNull Result result) {
        if (!(call.arguments instanceof Map)) {
            result.error("1", "Arguments Type Error.", "This method require a argument of Map, but you give a " + call.arguments.getClass());
            return;
        }
        Integer key = call.argument("key");
        if (key == null) {
            result.error("2", "'key' is absent", null);
            return;
        }
        Boolean active = call.argument("stats");
        if (active == null) {
            result.error("2", "'stats' is absent", null);
            return;
        }
        int _key = MouseKey.MouseKeyLBUTTON_VALUE;
        if (key == 1) {
            _key = MouseKey.MouseKeyMBUTTON_VALUE;
        } else if (key == 2) {
            _key = MouseKey.MouseKeyRBUTTON_VALUE;
        } else if (key == 3) {
            _key = MouseKey.MouseKeyXBUTTON1_VALUE;
        } else if (key == 4) {
            _key = MouseKey.MouseKeyXBUTTON2_VALUE;
        }

        Objects.requireNonNull(VeGameEngine.getInstance().getIODeviceManager()).sendInputMouseKey(_key, active ? KeySateType.DOWN : KeySateType.UP);
    }
    void onMouseMovementCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!(call.arguments instanceof Map)) {
            result.error("1", "Arguments Type Error.", "This method require a argument of Map, but you give a " + call.arguments.getClass());
            return;
        }
        Number deltaX = call.argument("deltaX");
        if (deltaX == null) {
            result.error("2", "'deltaX' is absent", null);
            return;
        }
        Number deltaY = call.argument("deltaY");
        if (deltaY == null) {
            result.error("2", "'deltaY' is absent", null);
            return;
        }
        Objects.requireNonNull(VeGameEngine.getInstance().getIODeviceManager()).sendInputMouseMove(deltaY.intValue(), deltaY.intValue());
    }
    void onMousePositionCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!(call.arguments instanceof Map)) {
            result.error("1", "Arguments Type Error.", "This method require a argument of Map, but you give a " + call.arguments.getClass());
            return;
        }
        Number x = call.argument("x");
        if (x == null) {
            result.error("2", "'x' is absent", null);
            return;
        }
        Number y = call.argument("y");
        if (y == null) {
            result.error("2", "'y' is absent", null);
            return;
        }
        Objects.requireNonNull(VeGameEngine.getInstance().getIODeviceManager()).sendInputCursorPos(x.floatValue(), y.floatValue());
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
        Log.i(TAG, "onFirstAudioFrame");
        methodChannel.invokeMethod("onFirstAudioFrame", new HashMap<String, String>(){{
            put("streamId", s);
        }});
    }

    @Override
    public void onFirstRemoteVideoFrame(String s) {
        Log.i(TAG, "onFirstVideoFrame");
        methodChannel.invokeMethod("onFirstVideoFrame", new HashMap<String, String>(){{
            put("streamId", s);
        }});
    }

    @Override
    public void onStreamStarted() {
        Log.i(TAG, "onStreamStarted");
        methodChannel.invokeMethod("onStreamStarted", null);
    }

    @Override
    public void onStreamPaused() {
        Log.i(TAG, "onStreamPaused");
        methodChannel.invokeMethod("onStreamPaused", null);
    }

    @Override
    public void onStreamResumed() {
        Log.i(TAG, "onStreamResumed");
        methodChannel.invokeMethod("onStreamResumed", null);
    }

    @Override
    public void onStreamStats(StreamStats stats) {
        Log.i(TAG, "onStreamStats");
        methodChannel.invokeMethod("onStreamStats", new HashMap<String, Object>(){{
            put("receivedVideoBitRate", stats.getReceivedVideoBitRate());
            put("receivedAudioBitRate", stats.getReceivedAudioBitRate());
            put("decoderOutputFrameRate", stats.getDecoderOutputFrameRate());
            put("rendererOutputFrameRate", stats.getRendererOutputFrameRate());
            put("receivedResolutionHeight", stats.getReceivedResolutionHeight());
            put("receivedResolutionWidth", stats.getReceivedResolutionWidth());
            put("videoLossRate", stats.getVideoLossRate());
            put("rtt", stats.getRtt());
            put("stallCount", stats.getStallCount());
            put("stallDuration", stats.getStallDuration());
            put("frozenRate", stats.getFrozenRate());
        }});
    }

    @Override
    public void onLocalStreamStats(LocalStreamStats localStreamStats) {

    }

    @Override
    public void onStreamConnectionStateChanged(int i) {
        Log.i(TAG, "onStreamConnectionStateChanged");
        methodChannel.invokeMethod("onStreamConnectionStateChanged", new HashMap<String, Integer>(){{
            put("stats", i);
        }});
    }

    @Override
    public void onDetectDelay(long l) {
        Log.i(TAG, "onDetectDelay");
        methodChannel.invokeMethod("onDetectDelay", new HashMap<String, Number>(){{
            put("elapse", l);
        }});
    }

    @Override
    public void onRotation(int i) {
        Log.i(TAG, "onRotation");
        methodChannel.invokeMethod("onRotation", new HashMap<String, Number>(){{
            put("rotation", i);
        }});
    }

    @Override
    public void onPodExit(int i, String s) {
        Log.i(TAG, "onPodExit");
        methodChannel.invokeMethod("onPodExit", new HashMap<String, Object>(){{
            put("reason", i);
            put("msg", s);
        }});
    }

    @Override
    public void onNetworkQuality(int i) {

    }
}

package cn.stormyang.ve_game_view.ve_game_view;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.volcengine.androidcloud.common.model.StreamStats;
import com.volcengine.cloudcore.common.mode.KeySateType;
import com.volcengine.cloudcore.common.mode.LocalStreamStats;
import com.volcengine.cloudcore.common.mode.MouseKey;
import com.volcengine.cloudcore.common.mode.QueueInfo;
import com.volcengine.cloudcore.common.mode.RenderViewType;
import com.volcengine.cloudcore.common.mode.Role;
import com.volcengine.cloudcore.common.mode.StreamType;
import com.volcengine.cloudgame.GamePlayConfig;
import com.volcengine.cloudgame.VeGameEngine;
import com.volcengine.cloudphone.apiservice.IMessageChannel;
import com.volcengine.cloudphone.apiservice.IODeviceManager;
import com.volcengine.cloudphone.apiservice.outinterface.ICloudCoreManagerStatusListener;
import com.volcengine.cloudphone.apiservice.outinterface.IGamePlayerListener;
import com.volcengine.cloudphone.apiservice.outinterface.IStreamListener;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

public class VeGameView implements PlatformView, MethodCallHandler, IGamePlayerListener, IStreamListener, ICloudCoreManagerStatusListener, IMessageChannel.IMessageReceiver {
    private final String TAG = "VeGameView";
    @NonNull
    private final FrameLayout mContainer;

    @NonNull
    private final MethodChannel flutterMethodChannel;

    private IMessageChannel cloudMessageChannel;

    /// 客户端发送的消息记录，SDK返回成功后回调到客户端
    private final Map<String, Result> channelMessageMap = new HashMap<>();

    /// 记录SDK的消息通道是否可用，不可用需要将客户端的消息暂存，然后等到可用时，再次发送
    private boolean messageChannelReady = false;
    private final List<SendMessageEntry> messageQueue = new ArrayList<>();

    private Integer roundId = 0;

    VeGameView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, @NonNull BinaryMessenger binaryMessenger, Activity activity) {
        mContainer = new FrameLayout(activity);
        mContainer.setLayoutParams(new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
        ));
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

        flutterMethodChannel = new MethodChannel(binaryMessenger, Constants.GAME_TYPE_ID + "." + id);
        flutterMethodChannel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        return mContainer;
    }

    @Override
    public void dispose() {
        if (cloudMessageChannel != null) {
            cloudMessageChannel.setMessageListener(null);
            cloudMessageChannel = null;
        }
        flutterMethodChannel.setMethodCallHandler(null);
        VeGameEngine.getInstance().stop();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String logStr = "onFlutterMethodCall: " + call.method;
        if (call.arguments != null) {
            logStr += ", args: " + call.arguments;
        }
        Log.i(TAG, logStr);
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
        } else if ("sendMessage".equals(call.method)) {
            onSendMessageCall(call, result);
        } else {
            result.notImplemented();
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
        String customGameId = call.argument("customGameId");
        if ((gameId == null || gameId.isEmpty()) && (customGameId == null || customGameId.isEmpty())) {
            result.error("2", "'gameId' or 'customGameId' is absent", null);
            return;
        }
        String roundId = call.argument("roundId");
        if (roundId == null) {
            roundId = uid + (++this.roundId);
        }

        GamePlayConfig.Builder builder = new GamePlayConfig.Builder();
        builder.userId(uid).ak(ak).sk(sk).token(token).gameId(gameId == null ? "" : gameId)
                .customGameId(customGameId)
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
        Integer roomType = call.argument("roomType");
        if (roomType != null) {
            builder.roomType(roomType);
        }
        Integer role = call.argument("role");
        if (role != null) {
            builder.role(role == 0 ? Role.VIEWER : Role.PLAYER);
        }
        String planId = call.argument("planId");
        if (planId != null) {
            builder.planId(planId);
        }
        Boolean keyBoardEnable = call.argument("keyBoardEnable");
        builder.keyBoardEnable(Boolean.TRUE.equals(keyBoardEnable));

        Integer videoStreamProfileId = call.argument("videoStreamProfileId");
        if (videoStreamProfileId != null) {
            builder.videoStreamProfileId(videoStreamProfileId);
        }
        Integer autoRecycleTime = call.argument("autoRecycleTime");
        if (autoRecycleTime != null) {
            builder.autoRecycleTime(autoRecycleTime);
        }
        List<String> userProfilePath = call.argument("userProfilePath");
        if (userProfilePath != null) {
            builder.userProfilePath(userProfilePath);
        }
        Integer queuePriority = call.argument("queuePriority");
        if (queuePriority != null) {
            builder.queuePriority(queuePriority);
        }
        Map<String, String> extra = call.argument("extra");
        if (extra != null) {
            builder.extra(extra);
        }
        builder.renderViewType(RenderViewType.TEXTURE_VIEW);
        GamePlayConfig mGamePlayConfig = builder.build();
        VeGameEngine.getInstance().removeCloudCoreManagerListener(this);
        VeGameEngine.getInstance().addCloudCoreManagerListener(this);
        VeGameEngine.getInstance().start(mGamePlayConfig, this);
        result.success(null);
    }
    void onStopMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        VeGameEngine.getInstance().stop();
        result.success(null);
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
        IODeviceManager manager = VeGameEngine.getInstance().getIODeviceManager();
        if (manager == null) {
            result.error("2", "'IODeviceManager' is absent", null);
            return;
        }

        manager.sendInputMouseKey(_key, active ? KeySateType.DOWN : KeySateType.UP);
        result.success(null);
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
        IODeviceManager manager = VeGameEngine.getInstance().getIODeviceManager();
        if (manager == null) {
            result.error("2", "'IODeviceManager' is absent", null);
            return;
        }
        manager.sendInputMouseMove(deltaY.intValue(), deltaY.intValue());
        result.success(null);
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
        IODeviceManager manager = VeGameEngine.getInstance().getIODeviceManager();
        if (manager == null) {
            result.error("2", "'IODeviceManager' is absent", null);
            return;
        }
        manager.sendInputCursorPos(x.floatValue(), y.floatValue());
        result.success(null);
    }

    void onSendMessageCall(@NonNull MethodCall call, @NonNull Result result) {
        if (messageChannelReady) {
            Log.i(TAG, "message channel ready. sending...");
            sendMessageToRemote(new SendMessageEntry(call, result));
        } else {
            Log.i(TAG, "message channel [NOT] ready. queue...");
            messageQueue.add(new SendMessageEntry(call, result));
        }
    }

    private void sendMessageToRemote(@NonNull SendMessageEntry entry) {
        if (cloudMessageChannel == null) {
            entry.result.error("-1", "CloudMessageChannel not ready", null);
            return;
        }

        String message = entry.call.argument("message");
        if (message == null || message.isEmpty()) {
            entry.result.error("-1", "[message] MUST NOT BE empty", null);
            return;
        }
        Integer timeout = entry.call.argument("timeout");
        assert timeout != null;

        IMessageChannel.IChannelMessage sendMessage = cloudMessageChannel.sendMessage(message, timeout.longValue());
        if (sendMessage == null) {
            entry.result.success(false);
            return;
        }
        Log.i(TAG, new Date() + " send message, id: " + sendMessage.getMid());
        channelMessageMap.put(sendMessage.getMid(), entry.result);
    }

    @Override
    public void onPlaySuccess(String s, int i, Map<String, String> map, String s1, String s2) {
        Log.i(TAG, "onPlaySuccess");
        flutterMethodChannel.invokeMethod("onPlaySuccess", new HashMap<String, Object>(){{
            put("roundId", s);
            put("videoStreamProfileId", i);
            put("extra", map);
            put("gameId", s1);
            put("reservedId", s2);
        }});
    }

    @Override
    public void onReceiveMessage(IMessageChannel.IChannelMessage iChannelMessage) {
        Log.i(TAG, "onReceiveMessage");
    }

    @Override
    public void onReceiveBinaryMessage(IMessageChannel.IChannelBinaryMessage iChannelBinaryMessage) {
        Log.i(TAG, "onReceiveBinaryMessage");
    }

    @Override
    public void onSentResult(boolean b, String s) {
        Log.i(TAG, new Date() + " send message onSentResult id: " + s + ",result: " + b);
        Result result = channelMessageMap.get(s);
        if (result == null) {
            return;
        }
        channelMessageMap.remove(s);
        result.success(b);
    }

    /// 已弃用，可忽略
    @Override
    public void ready() {}

    @Override
    public void onError(int i, String s) {
        Log.i(TAG, "onError, i:" + i + ", s: " + s);
        VeGameEngine.getInstance().stop();
        flutterMethodChannel.invokeMethod("onError", new HashMap<String, Object>(){{
            put("code", i);
            put("message", s);
        }});
    }

    @Override
    public void onRemoteOnline(String s) {
        Log.i(TAG, "message channel online");
        messageChannelReady = true;
        checkMessageQueue();
    }

    private void checkMessageQueue() {
        if (!messageQueue.isEmpty()) {
            List<SendMessageEntry> messages = new ArrayList<>(messageQueue);
            messageQueue.clear();
            for (SendMessageEntry entry :messages) {
                sendMessageToRemote(entry);
            }
        }
    }

    @Override
    public void onRemoteOffline(String s) {
        Log.i(TAG, "message channel offline");
        messageChannelReady = false;
//        makePendingMessageFailed();
    }

    private void makePendingMessageFailed() {
        for (Result result : channelMessageMap.values()) {
            result.success(false);
        }
    }

    @Override
    public void onWarning(int i, String s) {
        Log.i(TAG, "onWarning, i:" + i + ", s: " + s);
        flutterMethodChannel.invokeMethod("onWarning", new HashMap<String, Object>(){{
            put("code", i);
            put("message", s);
        }});
    }

    @Override
    public void onNetworkChanged(int i) {
        Log.i(TAG, "onWarning, i:" + i);
        flutterMethodChannel.invokeMethod("onNetworkChanged", new HashMap<String, Integer>(){{
            put("type", i);
        }});
    }

    @Override
    public void onServiceInit() {
        Log.i(TAG, "onServiceInit");
        flutterMethodChannel.invokeMethod("onServiceInit", null);
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
        flutterMethodChannel.invokeMethod("onQueueUpdate", queueInfoList);
    }

    @Override
    public void onQueueSuccessAndStart(int i) {
        Log.i(TAG, "onQueueSuccessAndStart");
        flutterMethodChannel.invokeMethod("onQueueSuccessAndStart", new HashMap<String, Integer>(){{
            put("remainTime", i);
        }});
    }

    @Override
    public void onFirstAudioFrame(String s) {
        Log.i(TAG, "onFirstAudioFrame");
        flutterMethodChannel.invokeMethod("onFirstAudioFrame", new HashMap<String, String>(){{
            put("streamId", s);
        }});
    }

    @Override
    public void onFirstRemoteVideoFrame(String s) {
        Log.i(TAG, "onFirstVideoFrame");
        flutterMethodChannel.invokeMethod("onFirstVideoFrame", new HashMap<String, String>(){{
            put("streamId", s);
        }});
    }

    @Override
    public void onStreamStarted() {
        Log.i(TAG, "onStreamStarted");
        flutterMethodChannel.invokeMethod("onStreamStarted", null);
    }

    @Override
    public void onStreamPaused() {
        Log.i(TAG, "onStreamPaused");
        flutterMethodChannel.invokeMethod("onStreamPaused", null);
    }

    @Override
    public void onStreamResumed() {
        Log.i(TAG, "onStreamResumed");
        flutterMethodChannel.invokeMethod("onStreamResumed", null);
    }

    @Override
    public void onStreamStats(StreamStats stats) {
        Log.i(TAG, "onStreamStats");
        flutterMethodChannel.invokeMethod("onStreamStats", new HashMap<String, Object>(){{
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
        flutterMethodChannel.invokeMethod("onStreamConnectionStateChanged", new HashMap<String, Integer>(){{
            put("stats", i);
        }});
    }

    @Override
    public void onDetectDelay(long l) {
        Log.i(TAG, "onDetectDelay");
        flutterMethodChannel.invokeMethod("onDetectDelay", new HashMap<String, Number>(){{
            put("elapse", l);
        }});
    }

    @Override
    public void onRotation(int i) {
        Log.i(TAG, "onRotation");
        flutterMethodChannel.invokeMethod("onRotation", new HashMap<String, Number>(){{
            put("rotation", i);
        }});
    }

    @Override
    public void onPodExit(int i, String s) {
        Log.i(TAG, "onPodExit");
        flutterMethodChannel.invokeMethod("onPodExit", new HashMap<String, Object>(){{
            put("reason", i);
            put("msg", s);
        }});
    }

    @Override
    public void onNetworkQuality(int i) {
        Log.i(TAG, "onNetworkQuality");
    }

    @Override
    public void onInitialed() {
        Log.i(TAG, "CloudCoreManager onInitialed");
    }

    @Override
    public void onPrepared() {
        Log.i(TAG, "CloudCoreManager onPrepared");
        setupMessageChannel();
    }

    private void setupMessageChannel() {
        cloudMessageChannel = VeGameEngine.getInstance().getMessageChannel();
        if (cloudMessageChannel != null) {
            cloudMessageChannel.setMessageListener(this);
        }
    }
}

package cn.stormyang.ve_game_view.ve_game_view;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.volcengine.androidcloud.common.model.StreamStats;
import com.volcengine.cloudcore.common.mode.LocalStreamStats;
import com.volcengine.cloudcore.common.mode.QueueInfo;
import com.volcengine.cloudcore.common.mode.Role;
import com.volcengine.cloudcore.common.mode.StreamType;
import com.volcengine.cloudgame.GamePlayConfig;
import com.volcengine.cloudgame.VeGameEngine;
import com.volcengine.cloudphone.apiservice.outinterface.IGamePlayerListener;
import com.volcengine.cloudphone.apiservice.outinterface.IStreamListener;

import java.util.List;
import java.util.Map;

public class VeGameInspectActivity extends AppCompatActivity implements IGamePlayerListener, IStreamListener {
    private final String TAG = "VeGameInspectActivity";
    private FrameLayout inspectContainer;
    private View loadingView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_cloud_inspect);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        initViews();

        Gson gson = new Gson();

        Intent intent = getIntent();
        GamePlayConfig.Builder builder = new GamePlayConfig.Builder();

        String uid = intent.getStringExtra("uid");
        if (uid != null) {
            Log.i(TAG, "uid: " + uid);
            builder.userId(uid);
        }

        String ak = intent.getStringExtra("ak");
        if (ak != null) {
            Log.i(TAG, "ak: " + ak);
            builder.ak(ak);
        }

        String sk = intent.getStringExtra("sk");
        if (sk != null) {
            Log.i(TAG, "sk: " + sk);
            builder.sk(sk);
        }

        String token = intent.getStringExtra("token");
        if (token != null) {
            Log.i(TAG, "token: " + token);
            builder.token(token);
        }

        String gameId = intent.getStringExtra("gameId");
        if (gameId != null) {
            Log.i(TAG, "gameId: " + gameId);
            builder.gameId(gameId);
        }

        String customGameId = intent.getStringExtra("customGameId");
        if (customGameId != null) {
            Log.i(TAG, "customGameId: " + customGameId);
            builder.customGameId(customGameId);
        }

        String roundId = intent.getStringExtra("roundId");
        if (roundId != null) {
            Log.i(TAG, "roundId: " + roundId);
            builder.roundId(roundId);
        }

        int streamType = intent.getIntExtra("streamType", 2);
        Log.i(TAG, "streamType: " + streamType);
        builder.streamType(StreamType.valueOf(streamType));

        String reservedId = intent.getStringExtra("reservedId");
        if (reservedId != null) {
            Log.i(TAG, "reservedId: " + reservedId);
            builder.reservedId(reservedId);
        }

        int sessionMode = intent.getIntExtra("sessionMode", 0);
        Log.i(TAG, "sessionMode: " + sessionMode);
        builder.sessionMode(sessionMode);

        int roomType = intent.getIntExtra("roomType", 0);
        Log.i(TAG, "roomType: " + roomType);
        builder.roomType(roomType);

        int role = intent.getIntExtra("role", 0);
        Log.i(TAG, "role: " + role);
        builder.role(role == 0 ? Role.VIEWER : Role.PLAYER);

        String planId = intent.getStringExtra("planId");
        if (planId != null) {
            Log.i(TAG, "planId: " + planId);
            builder.planId(planId);
        }

        boolean keyBoardEnable = intent.getBooleanExtra("keyBoardEnable", true);
        Log.i(TAG, "keyBoardEnable: " + keyBoardEnable);
        builder.keyBoardEnable(keyBoardEnable);

        int videoStreamProfileId = intent.getIntExtra("videoStreamProfileId", 1);
        Log.i(TAG, "videoStreamProfileId: " + videoStreamProfileId);
        builder.videoStreamProfileId(videoStreamProfileId);

        int autoRecycleTime = intent.getIntExtra("autoRecycleTime", 0);
        Log.i(TAG, "autoRecycleTime: " + autoRecycleTime);
        if (autoRecycleTime > 0) {
            builder.autoRecycleTime(autoRecycleTime);
        }

        String userProfilePath = intent.getStringExtra("userProfilePath");
        if (userProfilePath != null) {
            List<String> paths = gson.fromJson(userProfilePath, new TypeToken<List<String>>(){}.getType());
            Log.i(TAG, "userProfilePath: " + paths);
            builder.userProfilePath(paths);
        }

        int queuePriority = intent.getIntExtra("queuePriority", 0);
        Log.i(TAG, "queuePriority: " + queuePriority);
        builder.queuePriority(queuePriority);

        String extra = intent.getStringExtra("extra");
        if (extra != null) {
            Map<String, String> extras = gson.fromJson(extra, new TypeToken<Map<String, String>>(){}.getType());
            Log.i(TAG, "extra: " + extras);
            builder.extra(extras);
        }
        builder.container(inspectContainer).streamListener(this);

        GamePlayConfig config = builder.build();
        VeGameEngine.getInstance().start(config, this);
    }

    private void initViews() {
        inspectContainer = findViewById(R.id.container);
        loadingView = findViewById(R.id.loading);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        VeGameEngine.getInstance().stop();
    }

    @Override
    public void onPlaySuccess(String s, int i, Map<String, String> map, String s1, String s2) {
        Log.i(TAG, "onPlaySuccess");
    }

    @Override
    public void onError(int i, String s) {
        Log.e(TAG, "onError, i:" + i + ", s: " + s);
        loadingView.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onWarning(int i, String s) {
        Log.w(TAG, "onWarning, i:" + i + ", s: " + s);
    }

    @Override
    public void onNetworkChanged(int i) {
        Log.i(TAG, "onWarning, i:" + i);
    }

    @Override
    public void onServiceInit() {

        Log.i(TAG, "onServiceInit");
    }

    @Override
    public void onQueueUpdate(List<QueueInfo> list) {

        Log.i(TAG, "onQueueUpdate");
    }

    @Override
    public void onQueueSuccessAndStart(int i) {

        Log.i(TAG, "onQueueSuccessAndStart");
    }

    @Override
    public void onFirstAudioFrame(String s) {
        Log.i(TAG, "onFirstAudioFrame");

    }

    @Override
    public void onFirstRemoteVideoFrame(String s) {
        Log.i(TAG, "onFirstVideoFrame");
        loadingView.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onStreamStarted() {
        Log.i(TAG, "onStreamStarted");

    }

    @Override
    public void onStreamPaused() {
        Log.i(TAG, "onStreamPaused");

    }

    @Override
    public void onStreamResumed() {
        Log.i(TAG, "onStreamResumed");

    }

    @Override
    public void onStreamStats(StreamStats streamStats) {
        Log.i(TAG, "onStreamStats");

    }

    @Override
    public void onLocalStreamStats(LocalStreamStats localStreamStats) {

    }

    @Override
    public void onStreamConnectionStateChanged(int i) {
        Log.i(TAG, "onStreamConnectionStateChanged");

    }

    @Override
    public void onDetectDelay(long l) {
        Log.i(TAG, "onDetectDelay");

    }

    @Override
    public void onRotation(int i) {
        Log.i(TAG, "onRotation");

    }

    @Override
    public void onPodExit(int i, String s) {
        Log.i(TAG, "onPodExit");

    }

    @Override
    public void onNetworkQuality(int i) {

    }
}
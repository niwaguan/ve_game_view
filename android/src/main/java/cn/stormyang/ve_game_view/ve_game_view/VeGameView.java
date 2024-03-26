package cn.stormyang.ve_game_view.ve_game_view;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class VeGameView implements PlatformView, MethodChannel.MethodCallHandler {
    @NonNull
    private final TextView textView;

    private final MethodChannel methodChannel;

    VeGameView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, @NonNull BinaryMessenger binaryMessenger) {
        textView = new TextView(context);
        textView.setTextSize(72);
        textView.setBackgroundColor(Color.rgb(255, 255, 255));
        textView.setText("Rendered on a native Android view (id: " + id + ")");
        methodChannel = new MethodChannel(binaryMessenger, Constants.GAME_TYPE_ID + "." + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        return textView;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }
}

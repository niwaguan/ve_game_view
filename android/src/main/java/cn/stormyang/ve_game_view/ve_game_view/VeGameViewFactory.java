package cn.stormyang.ve_game_view.ve_game_view;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class VeGameViewFactory extends PlatformViewFactory {
    private final BinaryMessenger binaryMessenger;
    public VeGameViewFactory(BinaryMessenger binaryMessenger) {
        super(StandardMessageCodec.INSTANCE);
        this.binaryMessenger = binaryMessenger;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new VeGameView(context, viewId, creationParams, binaryMessenger);
    }
}

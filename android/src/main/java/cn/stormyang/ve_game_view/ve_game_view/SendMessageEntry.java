package cn.stormyang.ve_game_view.ve_game_view;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SendMessageEntry {
    @NonNull
    final MethodCall call;
    @NonNull
    final MethodChannel.Result result;

    public SendMessageEntry(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        this.call = call;
        this.result = result;
    }
}

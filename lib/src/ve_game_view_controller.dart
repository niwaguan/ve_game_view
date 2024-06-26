import 'package:flutter/services.dart';
import 'package:ve_game_view/src/model/ve_game_mouse_key.dart';

import 'constants.dart';
import 'model/stream_stats.dart';
import 'model/ve_game_config.dart';
import 'model/ve_game_queue_info.dart';

class VeGameViewController {
  final MethodChannel _channel;

  final void Function(List<QueueInfo> queueInfoList)? onQueueUpdate;
  final void Function(int remainTime)? onQueueSuccessAndStart;
  final void Function(int code, String message)? onWarning;
  final void Function(int code, String message)? onError;
  final void Function(String streamId)? onFirstAudioFrame;
  final void Function(String? streamId)? onFirstVideoFrame;
  final void Function()? onStreamStarted;
  final void Function()? onStreamPaused;
  final void Function()? onStreamResumed;
  final void Function(StreamStats streamStats)? onStreamStats;
  final void Function(int state)? onStreamConnectionStateChanged;
  final void Function(int elapse)? onDetectDelay;
  final void Function(int rotation)? onRotation;
  final void Function(int reason, String msg)? onPodExit;
  final void Function(int quality)? onNetworkQuality;

  VeGameViewController(
    int viewId, {
    this.onQueueUpdate,
    this.onQueueSuccessAndStart,
    this.onWarning,
    this.onError,
    this.onFirstAudioFrame,
    this.onFirstVideoFrame,
    this.onStreamStarted,
    this.onStreamPaused,
    this.onStreamResumed,
    this.onStreamStats,
    this.onStreamConnectionStateChanged,
    this.onDetectDelay,
    this.onRotation,
    this.onPodExit,
    this.onNetworkQuality,
  }) : _channel = MethodChannel('$viewTypeId.$viewId') {
    _channel.setMethodCallHandler(_onHostCall);
  }

  /// 启动游戏
  Future<bool?> start(VeGameConfig config) {
    return _channel.invokeMethod<bool>("start", config.toJson());
  }

  stop() {
    _channel.invokeMethod("stop");
  }

  /// 向云端发送消息
  /// [message] 消息内容
  /// [timeout] 超时时间
  Future<bool?> sendMessage(String message,
      {Duration timeout = const Duration(seconds: 2)}) {
    return _channel.invokeMethod<bool>("sendMessage", {
      "message": message,
      "timeout": timeout.inMilliseconds,
    });
  }

  /// 发送鼠标按键事件
  /// [key] 按键类型
  /// [stats] 状态。0 按下，1 抬起
  sendMouseKeyChanged(VeGameMouseKey key, int stats) {
    _channel.invokeMethod("sendMouseKeyChanged", {
      "key": key.index,
      "stats": stats == 0,
    });
  }

  /// 发送鼠标移动事件。差量值。
  sendMouseMovement(double deltaX, double deltaY) {
    _channel.invokeMethod("sendMouseMovement", {
      "deltaX": deltaX,
      "deltaY": deltaY,
    });
  }

  /// 发送鼠标绝对位置。值为 0 ~ 1
  sendMousePosition(double x, double y) {
    _channel.invokeMethod("sendMousePosition", {
      "x": x,
      "y": y,
    });
  }

  /// 响应平台调用
  Future<dynamic> _onHostCall(MethodCall call) async {
    print(
        "[VE_GAME_VIEW] receive host call: ${call.method}, args: ${call.arguments}");
    try {
      if (call.method == "onQueueUpdate" && onQueueUpdate != null) {
        final args = call.arguments as List<Map<String, Object>>;
        final queueInfoList =
            args.map((e) => QueueInfo.fromJson(e)).toList(growable: false);
        onQueueUpdate!(queueInfoList);
      } else if (call.method == "onQueueSuccessAndStart" &&
          onQueueSuccessAndStart != null) {
        final remainTime = call.arguments["remainTime"] as int;
        onQueueSuccessAndStart!(remainTime);
      } else if (call.method == "onWarning" && onWarning != null) {
        final code = call.arguments["code"] as int;
        final message = call.arguments["message"] as String;
        onWarning!(code, message);
      } else if (call.method == "onError" && onError != null) {
        final code = call.arguments["code"] as int;
        final message = call.arguments["message"] as String;
        onError!(code, message);
      } else if (call.method == "onFirstAudioFrame" &&
          onFirstAudioFrame != null) {
        final id = call.arguments["streamId"];
        onFirstAudioFrame!(id);
      } else if (call.method == "onFirstVideoFrame" &&
          onFirstVideoFrame != null) {
        final id = call.arguments != null ? call.arguments["streamId"] : null;
        onFirstVideoFrame!(id);
      } else if (call.method == "onStreamStarted" && onStreamStarted != null) {
        onStreamStarted!();
      } else if (call.method == "onStreamPaused" && onStreamPaused != null) {
        onStreamPaused!();
      } else if (call.method == "onStreamResumed" && onStreamResumed != null) {
        onStreamResumed!();
      } else if (call.method == "onStreamStats" && onStreamStats != null) {
        final stats = StreamStats.fromJson(call.arguments);
        onStreamStats!(stats);
      } else if (call.method == "onStreamConnectionStateChanged" &&
          onStreamConnectionStateChanged != null) {
        final state = call.arguments["state"] as int;
        onStreamConnectionStateChanged!(state);
      } else if (call.method == "onDetectDelay" && onDetectDelay != null) {
        final elapse = call.arguments["elapse"] as int;
        onDetectDelay!(elapse);
      } else if (call.method == "onRotation" && onRotation != null) {
        final rotation = call.arguments["rotation"] as int;
        onRotation!(rotation);
      } else if (call.method == "onPodExit" && onPodExit != null) {
        final reason = call.arguments["reason"] as int;
        final msg = call.arguments["msg"] as String;
        onPodExit!(reason, msg);
      } else if (call.method == "onNetworkQuality" &&
          onNetworkQuality != null) {
        final quality = call.arguments["quality"] as int;
        onNetworkQuality!(quality);
      }
    } catch (e) {
      print("[VE_GAME] error: $e");
    }
  }
}

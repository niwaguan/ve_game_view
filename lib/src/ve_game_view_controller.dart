import 'package:flutter/services.dart';

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
  final void Function(String streamId)? onFirstVideoFrame;
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
  start(VeGameConfig config) {
    _channel.invokeMethod("start", config.toJson());
  }

  stop() {
    _channel.invokeMethod("stop");
  }

  /// 发送鼠标按键事件
  sendMouseKeyChanged() {}

  /// 响应平台调用
  Future<dynamic> _onHostCall(MethodCall call) async {
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
      final id = call.arguments["streamId"];
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
    } else if (call.method == "onNetworkQuality" && onNetworkQuality != null) {
      final quality = call.arguments["quality"] as int;
      onNetworkQuality!(quality);
    }
  }
}

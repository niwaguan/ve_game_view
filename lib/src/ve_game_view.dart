import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'model/stream_stats.dart';
import 'model/ve_game_queue_info.dart';
import 've_game_type.dart';
import 've_game_view_controller.dart';

class VeGameView extends StatelessWidget {
  const VeGameView({
    super.key,
    this.onCreated,
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
  });

  /// 创建实例后的回调
  final VeGameViewCreated? onCreated;

  /// 排队信息更新
  final void Function(List<QueueInfo> queueInfoList)? onQueueUpdate;

  /// 排队结束，开始申请资源：
  /// 支持 Android、iOS
  /// [remainTime]：当用户排到第0位时申请服务的等待时间，超过时间未进入会被移出队列
  final void Function(int remainTime)? onQueueSuccessAndStart;

  /// SDK 内部产生告警回调.
  /// 支持 Android、iOS
  /// [code] 警告码。参考
  ///   - Android https://bytedance.larkoffice.com/docs/doccnoP26zXzZkulwBmMYxazotc#DixrPW
  ///   - iOS https://bytedance.larkoffice.com/docs/doccn6FngLwusSb4L2kkbpwnjEs#DixrPW
  final void Function(int code, String message)? onWarning;

  /// SDK 内部产生错误回调。错误后，插件会自动停止。
  /// 支持 Android、iOS
  /// [code] 错误码。参考
  ///   - Android https://bytedance.larkoffice.com/docs/doccnoP26zXzZkulwBmMYxazotc#u4JzDI
  ///   - iOS https://bytedance.larkoffice.com/docs/doccn6FngLwusSb4L2kkbpwnjEs#6z6cxr
  final void Function(int code, String message)? onError;

  /// 收到音频首帧回调
  /// [streamId] 远端实例视频流 ID
  final void Function(String streamId)? onFirstAudioFrame;

  /// 收到视频首帧回调
  /// [streamId] 远端实例视频流 ID
  final void Function(String streamId)? onFirstVideoFrame;

  /// 开始播放回调
  final void Function()? onStreamStarted;

  /// 调用 pause()，暂停播放后的回调
  final void Function()? onStreamPaused;

  /// 调用 resume() 或 muteAudio(false)，恢复播放后的回调
  final void Function()? onStreamResumed;

  /// 视频流的当前性能状态回调（2秒周期内音视频网路状态的回调，可用于内部数据分析或监控）
  final void Function(StreamStats streamStats)? onStreamStats;

  /// 视频流连接状态变更回调：
  /// 1：连接断开
  /// 2：首次连接，正在连接中
  /// 3：首次连接成功
  /// 4：连接断开后重新连接中
  /// 5：连接断开后重连成功
  /// 6：网络连接断开超过 10 秒，仍然会继续重连
  final void Function(int state)? onStreamConnectionStateChanged;

  /// 当前操作延时回调，单位毫秒（操作延时获取是指在操作时发送到远端的消息，
  /// 本地记录的时间戳，收到远端视频流会带上操作延时的标记，从而计算出来的一个值，该值可以理解为操作和对应画面渲染更新的一个差值）
  final void Function(int elapse)? onDetectDelay;

  /// 旋转回调
  final void Function(int rotation)? onRotation;

  /// 退出回调，参考以下 onPodExit 相关信息
  ///   Android: https://bytedance.larkoffice.com/docs/doccnoP26zXzZkulwBmMYxazotc#Q3AoWS
  final void Function(int reason, String msg)? onPodExit;

  /// 游戏中网络质量回调，每隔 2 秒上报一次网络质量评级：
  /// [quality]：网络质量评级（可根据当前返回的网络质量评级进行推流参数降级或者终止拉流；详细信息，参考以下onNetworkQuality 相关信息）
  ///   Android https://bytedance.feishu.cn/docs/doccnoP26zXzZkulwBmMYxazotc#zT8tlp
  final void Function(int quality)? onNetworkQuality;

  _onPlatformViewCreated(int id) {
    final controller = VeGameViewController(
      id,
      onQueueUpdate: onQueueUpdate,
      onQueueSuccessAndStart: onQueueSuccessAndStart,
      onWarning: onWarning,
      onError: onError,
      onFirstAudioFrame: onFirstAudioFrame,
      onFirstVideoFrame: onFirstVideoFrame,
      onStreamStarted: onStreamStarted,
      onStreamPaused: onStreamPaused,
      onStreamResumed: onStreamResumed,
      onStreamStats: onStreamStats,
      onStreamConnectionStateChanged: onStreamConnectionStateChanged,
      onDetectDelay: onDetectDelay,
      onRotation: onRotation,
      onPodExit: onPodExit,
      onNetworkQuality: onNetworkQuality,
    );
    if (onCreated != null) {
      onCreated!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
          viewType: viewTypeId,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
            );
          },
          onCreatePlatformView: (params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewTypeId,
              layoutDirection: TextDirection.ltr,
              creationParams: null,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
              ..create();
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewTypeId,
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }
}

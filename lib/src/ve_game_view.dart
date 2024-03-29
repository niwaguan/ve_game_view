import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
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

  _onPlatformViewCreated(int id) {
    final controller = VeGameViewController(
      id,
      onQueueUpdate,
      onQueueSuccessAndStart,
      onWarning,
      onError,
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

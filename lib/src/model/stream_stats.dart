class StreamStats {
  /// 视频接收码率瞬时值（单位 kbps）
  final int receivedVideoBitRate;

  /// 音频接收码率瞬时值（单位 kbps）
  final int receivedAudioBitRate;

  /// 解码器输出帧率（单位 fps）
  final int decoderOutputFrameRate;

  /// 渲染帧率（单位 fps）
  final int rendererOutputFrameRate;

  /// 远端视频流高度
  final int receivedResolutionHeight;

  /// 远端视频流宽度
  final int receivedResolutionWidth;

  final double videoLossRate;

  final int rtt;

  final int stallCount;

  final int stallDuration;

  final int frozenRate;

  StreamStats(
      {required this.receivedVideoBitRate,
      required this.receivedAudioBitRate,
      required this.decoderOutputFrameRate,
      required this.rendererOutputFrameRate,
      required this.receivedResolutionHeight,
      required this.receivedResolutionWidth,
      required this.videoLossRate,
      required this.rtt,
      required this.stallCount,
      required this.stallDuration,
      required this.frozenRate});
}

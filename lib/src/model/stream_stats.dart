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

  /// 视频丢包率
  final double videoLossRate;

  /// 客户端与服务端往返时延（单位 ms） ios 是视频流延迟
  final int rtt;

  /// 卡顿次数 ios 是视频次数
  final int stallCount;

  /// 卡顿时长（统计周期内的视频卡顿总时长，单位 ms）  ios是视频卡顿时长
  final int stallDuration;

  /// 顿率（视频卡顿的累计时长占视频总有效时长的百分比） ios是远端视频接收码率
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

  StreamStats.fromJson(Map<Object?, Object?> obj)
      : receivedVideoBitRate = obj["receivedVideoBitRate"] as int,
        receivedAudioBitRate = obj["receivedAudioBitRate"] as int,
        decoderOutputFrameRate = obj["decoderOutputFrameRate"] as int,
        rendererOutputFrameRate = obj["rendererOutputFrameRate"] as int,
        receivedResolutionHeight = obj["receivedResolutionHeight"] as int,
        receivedResolutionWidth = obj["receivedResolutionWidth"] as int,
        videoLossRate = obj["videoLossRate"] as double,
        rtt = obj["rtt"] as int,
        stallCount = obj["stallCount"] as int,
        stallDuration = obj["stallDuration"] as int,
        frozenRate = obj["frozenRate"] as int;
}

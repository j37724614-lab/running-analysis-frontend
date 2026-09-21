class VideoPlayback {
  final int position; // 單位：毫秒
  final int duration; // 單位：毫秒
  final int currentFrame; // 根據 detection 計算出來
  final bool isDragging;

  const VideoPlayback({
    required this.position,
    required this.duration,
    required this.currentFrame,
    required this.isDragging,
  });

  VideoPlayback copyWith({int? position, int? duration, int? currentFrame, bool? isDragging}) {
    return VideoPlayback(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentFrame: currentFrame ?? this.currentFrame,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  static const initial = VideoPlayback(
    position: 0,
    duration: 1000,
    currentFrame: 0,
    isDragging: false,
  );
}

class Video360PlayInfo {
  Video360PlayInfo({
    required this.duration,
    required this.total,
    required this.isPlaying,
  });

  final int duration;
  final int total;
  final bool isPlaying;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Video360PlayInfo &&
        other.runtimeType == runtimeType &&
        other.duration == duration &&
        other.total == total &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        duration,
        total,
        isPlaying,
      );

  @override
  String toString() {
    return 'Video360PlayInfo('
        'duration: $duration, '
        'total: $total, '
        'isPlaying: $isPlaying, '
        ')';
  }

  Video360PlayInfo copyWith({
    int? duration,
    int? total,
    bool? isPlaying,
  }) {
    return Video360PlayInfo(
      duration: duration ?? this.duration,
      total: total ?? this.total,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

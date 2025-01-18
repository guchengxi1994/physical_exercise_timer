class MainScreenState {
  final bool isMaximized;
  final bool isCameraAvailable;
  final bool isCameraReady;
  final int cameraId;

  const MainScreenState({
    required this.isMaximized,
    required this.isCameraAvailable,
    required this.isCameraReady,
    this.cameraId = -1,
  });

  MainScreenState copyWith({
    bool? isMaximized,
    bool? isCameraReady,
    int? cameraId,
    bool? isCameraAvailable,
  }) {
    return MainScreenState(
      isMaximized: isMaximized ?? this.isMaximized,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      cameraId: cameraId ?? this.cameraId,
      isCameraAvailable: isCameraAvailable ?? this.isCameraAvailable,
    );
  }
}

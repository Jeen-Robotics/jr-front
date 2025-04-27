import 'dart:ui' as ui;
import 'package:equatable/equatable.dart';

class CameraState extends Equatable {
  final bool isInitialized;
  final int currentCameraIndex;
  final ui.Image? uiImage;
  final int numCameras;
  final bool isStreaming;
  final int imageWidth;
  final int imageHeight;

  const CameraState({
    this.isInitialized = false,
    this.currentCameraIndex = 0,
    this.uiImage,
    this.numCameras = 0,
    this.isStreaming = false,
    this.imageWidth = 1280,
    this.imageHeight = 720,
  });

  CameraState copyWith({
    bool? isInitialized,
    int? currentCameraIndex,
    ui.Image? uiImage,
    int? numCameras,
    bool? isStreaming,
    int? imageWidth,
    int? imageHeight,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
      uiImage: uiImage ?? this.uiImage,
      numCameras: numCameras ?? this.numCameras,
      isStreaming: isStreaming ?? this.isStreaming,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        currentCameraIndex,
        uiImage,
        numCameras,
        isStreaming,
        imageWidth,
        imageHeight,
      ];
}

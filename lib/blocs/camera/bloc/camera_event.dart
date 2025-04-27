import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraInitialize extends CameraEvent {
  final int? imageWidth;
  final int? imageHeight;
  final int? cameraIndex;

  const CameraInitialize({
    this.imageWidth,
    this.imageHeight,
    this.cameraIndex,
  });

  @override
  List<Object?> get props => [imageWidth, imageHeight, cameraIndex];
}

class CameraSwitch extends CameraEvent {}

class CameraStartStreaming extends CameraEvent {}

class CameraStopStreaming extends CameraEvent {}

class CameraImageReceived extends CameraEvent {
  final dynamic image;

  const CameraImageReceived(this.image);

  @override
  List<Object?> get props => [image];
}

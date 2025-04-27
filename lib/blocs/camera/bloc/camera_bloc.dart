import 'dart:ui' as ui;

import 'package:bloc/bloc.dart';
import 'package:jr_front/utils/image.dart';
import 'package:jr_front/jr_core/api/service.dart' as jr;

import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final jr.JRApiService? _jrApiService;

  CameraBloc(this._jrApiService) : super(const CameraState()) {
    on<CameraInitialize>(_onCameraInitialize);
    on<CameraSwitch>(_onCameraSwitch);
    on<CameraStartStreaming>(_onCameraStartStreaming);
    on<CameraStopStreaming>(_onCameraStopStreaming);
    on<CameraImageReceived>(_onCameraImageReceived);
  }

  Future<void> _onCameraInitialize(
    CameraInitialize event,
    Emitter<CameraState> emit,
  ) async {
    if (_jrApiService == null) return;

    try {
      print("Number of cameras: ${_jrApiService.numCameras}");
      emit(state.copyWith(numCameras: _jrApiService.numCameras));

      final didOpen = _jrApiService.openCamera(
        event.imageWidth ?? state.imageWidth,
        event.imageHeight ?? state.imageHeight,
        event.cameraIndex ?? state.currentCameraIndex,
      );

      if (didOpen) {
        emit(state.copyWith(
          isInitialized: true,
          currentCameraIndex: event.cameraIndex,
        ));
        add(CameraStartStreaming());
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _onCameraSwitch(
    CameraSwitch event,
    Emitter<CameraState> emit,
  ) async {
    if (_jrApiService == null) return;

    await _jrApiService.stopCameraStreaming();
    _jrApiService.closeCamera();

    emit(state.copyWith(isInitialized: false, isStreaming: false));

    final nextCameraIndex = (state.currentCameraIndex + 1) % state.numCameras;
    final didOpen = _jrApiService.openCamera(
      state.imageWidth, // imageWidth
      state.imageHeight, // imageHeight
      nextCameraIndex,
    );

    emit(state.copyWith(
      isInitialized: didOpen,
      currentCameraIndex: nextCameraIndex,
    ));

    if (didOpen) {
      add(CameraStartStreaming());
    }
  }

  void _onCameraStartStreaming(
    CameraStartStreaming event,
    Emitter<CameraState> emit,
  ) {
    if (_jrApiService == null || !state.isInitialized) {
      return;
    }

    _jrApiService.startCameraStreaming((image) async {
      if (image.isEmpty) {
        return;
      }

      final uiImage = await imageFromBytes(
        image.data,
        image.width,
        image.height,
      );

      add(CameraImageReceived(uiImage));
    });

    emit(state.copyWith(isStreaming: true));
  }

  void _onCameraStopStreaming(
    CameraStopStreaming event,
    Emitter<CameraState> emit,
  ) {
    if (_jrApiService == null) return;

    _jrApiService.stopCameraStreaming();
    emit(state.copyWith(isStreaming: false));
  }

  void _onCameraImageReceived(
    CameraImageReceived event,
    Emitter<CameraState> emit,
  ) {
    final uiImage = event.image as ui.Image;

    if (state.uiImage != null) {
      state.uiImage!.dispose();
    }

    emit(state.copyWith(uiImage: uiImage));
  }

  @override
  Future<void> close() {
    if (_jrApiService != null) {
      _jrApiService.stopCameraStreaming();
      _jrApiService.closeCamera();
    }
    return super.close();
  }
}

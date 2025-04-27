import 'dart:async';
import 'dart:ffi';

import 'package:jr_front/utils/dlopen.dart';

import 'bindings.dart';
import 'image.dart';

typedef FrameCallback = void Function(JRImage frame);

final class JRApiService {
  final DynamicLibrary _lib;
  final JRApi _bindings;

  Pointer<jr_camera_device_t> _device;

  FrameCallback? _frameCallback;
  late NativeCallable<jr_camera_device_frame_callback_tFunction>
      _nativeFrameCallback;
  late NativeCallable<jr_camera_device_void_callback_tFunction>
      _nativeSessionCallback;

  Completer<void> _sessionCompleter = Completer<void>();

  JRApiService._(this._lib, this._bindings)
      : _device = _bindings.jr_camera_device_create() {
    void onSessionReadyCallback() {
      print("onSessionReady");
      _sessionCompleter.complete();
    }

    _nativeSessionCallback =
        NativeCallable<jr_camera_device_void_callback_tFunction>.listener(
      onSessionReadyCallback,
    );
    _bindings.jr_camera_device_set_session_ready_callback(
      _device,
      _nativeSessionCallback.nativeFunction,
    );
  }

  static JRApiService? init() {
    final lib = dlopen('jr_api');
    if (lib == null) {
      return null;
    }
    final bindings = JRApi(lib);
    return JRApiService._(lib, bindings);
  }

  void dispose() {
    stopCameraStreaming();
    if (_device != nullptr) {
      _bindings.jr_camera_device_destroy(_device);
      _device = nullptr;
    }
    _lib.close();
  }

  int get numCameras =>
      _bindings.jr_camera_device_get_number_of_cameras(_device);

  bool openCamera(int width, int height, int cameraIdx) {
    return _bindings.jr_camera_device_open(
      _device,
      width,
      height,
      cameraIdx,
    );
  }

  void closeCamera() {
    _bindings.jr_camera_device_close(_device);
  }

  bool startCameraStreaming(FrameCallback callback) {
    if (_device == nullptr) {
      return false;
    }

    _sessionCompleter = Completer<void>();

    _frameCallback = callback;

    // Create a NativeCallable that properly handles isolate safety
    void onFrameCallback(
      jr_image_t data,
      Pointer<Void> userData,
    ) {
      _frameCallback?.call(JRImage(data));
    }

    _nativeFrameCallback =
        NativeCallable<jr_camera_device_frame_callback_tFunction>.listener(
      onFrameCallback,
    );

    _bindings.jr_camera_device_set_frame_callback(
      _device,
      _nativeFrameCallback.nativeFunction,
      nullptr,
    );

    return _bindings.jr_camera_device_start_streaming(
      _device,
    );
  }

  Future<void> stopCameraStreaming() async {
    if (_device != nullptr) {
      _bindings.jr_camera_device_stop_streaming(_device);
    }

    // Close the NativeCallable when no longer needed
    if (_frameCallback != null) {
      _nativeFrameCallback.close();
      _frameCallback = null;
    }

    await _sessionCompleter.future;
    // NOTE: This is a hack to ensure the session is ready before closing the camera
    await Future.delayed(const Duration(seconds: 1));
  }
}

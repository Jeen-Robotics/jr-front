import 'dart:ffi';
import 'dart:typed_data';
import 'bindings.dart';
import 'package:jr_front/utils/dlopen.dart';

typedef FrameCallback = void Function(Uint8List frame);

final class CameraService {
  final DynamicLibrary _lib;
  final Camera _bindings;
  Pointer<jr_android_camera_streamer_t>? _streamer;
  static FrameCallback? _frameCallback;
  late NativeCallable<jr_android_camera_frame_callback_tFunction> _nativeCallback;

  CameraService._(this._lib, this._bindings);

  static CameraService? init() {
    final lib = dlopen('camera');
    if (lib == null) {
      return null;
    }
    final bindings = Camera(lib);
    return CameraService._(lib, bindings);
  }

  void dispose() {
    stopStreaming();
    if (_streamer != null) {
      _bindings.jr_android_camera_streamer_destroy(_streamer!);
      _streamer = null;
    }
    _lib.close();
  }

  bool initialize(int width, int height, int format) {
    _streamer ??= _bindings.jr_android_camera_streamer_create();

    final result = _bindings.jr_android_camera_streamer_initialize(
      _streamer!,
      width,
      height,
      format,
    );

    return result == 1;
  }

  static void _onFrameCallback(Pointer<Uint8> data, int size, Pointer<Void> userData) {
    final frame = data.asTypedList(size);
    _frameCallback?.call(frame);
  }

  bool startStreaming(FrameCallback callback) {
    if (_streamer == null) {
      return false;
    }

    _frameCallback = callback;

    // Create a NativeCallable that properly handles isolate safety
    _nativeCallback = NativeCallable<jr_android_camera_frame_callback_tFunction>.listener(
      _onFrameCallback,
    );

    _bindings.jr_android_camera_streamer_set_frame_callback(
      _streamer!,
      _nativeCallback.nativeFunction,
      nullptr,
    );

    final result = _bindings.jr_android_camera_streamer_start_streaming(
      _streamer!,
    );

    return result == 1;
  }

  void stopStreaming() {
    if (_streamer != null) {
      _bindings.jr_android_camera_streamer_stop_streaming(_streamer!);
    }
    
    // Close the NativeCallable when no longer needed
    if (_frameCallback != null) {
      _nativeCallback.close();
      _frameCallback = null;
    }
  }
}

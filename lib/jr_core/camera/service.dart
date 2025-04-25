import 'dart:ffi';
import 'dart:typed_data';
import 'bindings.dart';
import 'package:jr_front/utils/dlopen.dart';
import 'package:ffi/ffi.dart';

final class CameraService {
  final DynamicLibrary _lib;
  final Camera _bindings;

  Pointer<Uint8> _framePtr = nullptr;

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
    if (_framePtr != nullptr) {
      malloc.free(_framePtr);
    }

    _lib.close();
  }

  Uint8List? yuv2rgba(
    Uint8List y,
    Uint8List u,
    Uint8List v, 
    int width,
    int height,
  ) {
    // Allocate Pointers for the YUV data
    final yPtr = malloc<Uint8>(y.length);
    final uPtr = malloc<Uint8>(u.length);
    final vPtr = malloc<Uint8>(v.length);

    // Copy data directly using address
    yPtr.asTypedList(y.length).setAll(0, y);
    uPtr.asTypedList(u.length).setAll(0, u);
    vPtr.asTypedList(v.length).setAll(0, v);

    // Process the frame
    if (_framePtr != nullptr) {
      malloc.free(_framePtr);
    }
    _framePtr = _bindings.yuv2rgba(yPtr, uPtr, vPtr, width, height);

    // Free the YUV pointers
    malloc.free(yPtr);
    malloc.free(uPtr);
    malloc.free(vPtr);

    if (_framePtr == nullptr) {
      return null;
    }

    // Get the RGBA data and free the frame pointer
    return _framePtr.asTypedList(width * height * 4);
  }
}

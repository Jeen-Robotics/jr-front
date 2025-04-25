import 'dart:ffi';
import 'dart:typed_data';
import 'bindings.dart';
import 'package:jr_front/utils/dlopen.dart';

final class CameraService {
  late final DynamicLibrary _lib;
  late final Camera _bindings;

  CameraService() {
    _lib = dlopen('camera');
    _bindings = Camera(_lib);
  }

  void initializeCamera() => _bindings.initializeCamera();

  bool isCameraInitialized() => _bindings.isCameraInitialized();

  void stopCamera() => _bindings.stopCamera();

  Uint8List? processFrame(int width, int height) {
    final framePtr = _bindings.processFrame(width, height);
    if (framePtr == nullptr) {
      return null;
    }

    return framePtr.asTypedList(width * height * 4);
  }
}

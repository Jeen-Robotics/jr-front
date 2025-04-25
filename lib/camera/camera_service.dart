import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

final class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  StreamController<CameraImage>? _imageStreamController;
  bool _isStreaming = false;
  List<CameraDescription> _availableCameras = [];

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  bool get isStreaming => _isStreaming;
  List<CameraDescription> get cameras => _availableCameras;

  final ResolutionPreset _resolutionPreset = ResolutionPreset.low;
  final ImageFormatGroup _imageFormatGroup = ImageFormatGroup.yuv420;

  Future<void> initialize() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        _availableCameras.first,
        _resolutionPreset,
        enableAudio: false,
        imageFormatGroup: _imageFormatGroup,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
    }
  }

  /// Switches to a different camera
  Future<void> switchCamera(CameraDescription camera) async {
    if (!_isInitialized) {
      throw Exception('Camera service not initialized');
    }

    // Stop current stream if running
    final wasStreaming = _isStreaming;
    if (wasStreaming) {
      await stopImageStream();
    }

    // Dispose current controller
    await _controller?.dispose();

    // Initialize new controller
    _controller = CameraController(
      camera,
      _resolutionPreset,
      enableAudio: false,
      imageFormatGroup: _imageFormatGroup,
    );

    await _controller!.initialize();

    // Restart stream if it was running
    if (wasStreaming) {
      startImageStream();
    }
  }

  Future<void> dispose() async {
    await stopImageStream();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  /// Starts streaming camera images and returns a stream of CameraImage objects
  Stream<CameraImage> startImageStream() {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_imageStreamController != null) {
      return _imageStreamController!.stream;
    }

    _imageStreamController = StreamController<CameraImage>();
    _isStreaming = true;

    _controller!.startImageStream((CameraImage image) {
      if (_isStreaming) {
        _imageStreamController?.add(image);
      }
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('Error in image stream: $error');
      _imageStreamController?.addError(error, stackTrace);
    });

    return _imageStreamController!.stream;
  }

  /// Stops the image stream and cleans up resources
  Future<void> stopImageStream() async {
    _isStreaming = false;
    await _controller?.stopImageStream();
    await _imageStreamController?.close();
    _imageStreamController = null;
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      await _controller!.startVideoRecording();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      return await _controller!.stopVideoRecording();
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }
} 
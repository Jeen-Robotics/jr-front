import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'jr_core/camera/service.dart';
import 'utils/image.dart';
import 'widget/image_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCV Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _cameraService = CameraService();
  ui.Image? _currentFrame;
  bool _isInitialized = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _cameraService.initializeCamera();
    setState(() {
      _isInitialized = _cameraService.isCameraInitialized();
    });
    if (_isInitialized) {
      _startCameraStream();
    }
  }

  void _startCameraStream() {
    const int width = 640;
    const int height = 480;
    _timer = Timer.periodic(const Duration(milliseconds: 33), (timer) async {
      final frame = _cameraService.processFrame(width, height);
      if (frame == null) {
        return;
      }

      final image = await imageFromBytes(frame, width, height);

      setState(() {
        if (_currentFrame != null) {
          _currentFrame!.dispose();
        }

        _currentFrame = image;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraService.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeen Robotics Front'),
      ),
      body: _isInitialized
          ? _currentFrame != null
              ? Center(
                  child: CustomPaint(
                    size: const Size(640, 480),
                    painter: ImagePainter(_currentFrame!),
                  ),
                )
              : const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text('Failed to initialize camera'),
            ),
    );
  }
}

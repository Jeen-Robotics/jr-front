import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'jr_core/camera/service.dart' as jr;

import 'camera/camera_service.dart';
import 'gps/gps_service.dart';
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
      title: 'Jeen Robotics Front',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
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
  final CameraService _cameraService = CameraService();
  final _gpsService = GPSService(const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
  ));
  late final jr.CameraService? _jrCameraService;
  bool _isCameraInitialized = false;
  bool _isGpsInitialized = false;
  Position? _currentLocation;
  StreamSubscription<CameraImage>? _imageStreamSubscription;
  int _currentCameraIndex = 0;
  ui.Image? _uiImage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _initializeCamera();
    await _initializeGPS();
  }

  Future<void> _initializeGPS() async {
    final gpsInitialized = await _gpsService.initialize();
    if (gpsInitialized) {
      setState(() {
        _isGpsInitialized = true;
      });
      await _startLocationUpdates();
    }
  }

  Future<void> _startLocationUpdates() async {
    await Future.delayed(const Duration(seconds: 1));

    final lastKnownLocation = await _gpsService.getLastKnownLocation();
    print("lastKnownLocation: $lastKnownLocation");
    setState(() {
      _currentLocation = lastKnownLocation;
    });

    final location = await _gpsService.getCurrentLocation(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
        timeLimit: Duration(seconds: 5),
      ),
    );
    print("location: $location");
    setState(() {
      _currentLocation = location;
    });

    _gpsService.getLocationStream().listen((location) {
      setState(() {
        _currentLocation = location;
      });
    });
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {
        _isCameraInitialized = _cameraService.isInitialized;
      });

      if (_isCameraInitialized) {
        _jrCameraService = jr.CameraService.init();
        _startCameraStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startCameraStream() {
    final imageStream = _cameraService.startImageStream();

    _imageStreamSubscription = imageStream.listen((CameraImage image) async {
      // final rgba = rgbaFromCameraImage(image);

      final rgba = _jrCameraService?.yuv2rgba(
        image.planes[0].bytes,
        image.planes[1].bytes,
        image.planes[2].bytes,
        image.width,
        image.height,
      );
      if (rgba == null) {
        return;
      }

      final uiImage = await imageFromBytes(rgba, image.width, image.height);
      setState(() {
        if (_uiImage != null) {
          _uiImage!.dispose();
        }
        _uiImage = uiImage;
      });
    });
  }

  int _getQuarterTurns(DeviceOrientation orientation) {
    const Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 3,
      DeviceOrientation.landscapeRight: 2,
      DeviceOrientation.portraitDown: 1,
      DeviceOrientation.landscapeLeft: 0,
    };
    return turns[orientation]!;
  }

  Future<void> _switchCamera() async {
    if (!_isCameraInitialized || _cameraService.cameras.length <= 1) return;

    setState(() {
      _isCameraInitialized = false;
    });

    _imageStreamSubscription?.cancel();
    _imageStreamSubscription = null;

    _currentCameraIndex =
        (_currentCameraIndex + 1) % _cameraService.cameras.length;
    await _cameraService
        .switchCamera(_cameraService.cameras[_currentCameraIndex]);

    setState(() {
      _isCameraInitialized = _cameraService.isInitialized;
    });

    if (_isCameraInitialized) {
      _startCameraStream();
    }
  }

  @override
  void dispose() {
    _imageStreamSubscription?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized
              ? _uiImage != null
                  ? Center(
                      child: RotatedBox(
                        quarterTurns: _getQuarterTurns(
                          _cameraService.controller!.value.deviceOrientation,
                        ),
                        child: CustomPaint(
                          size: Size(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                          ),
                          painter: ImagePainter(
                            _uiImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : _cameraService.controller != null
                      ? Center(child: CameraPreview(_cameraService.controller!))
                      : const Center(
                          child: Text('Failed to initialize camera'),
                        )
              : const Center(child: CircularProgressIndicator()),
          if (_isGpsInitialized && _currentLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}\n'
                  'Lon: ${_currentLocation!.longitude.toStringAsFixed(6)}\n'
                  'Alt: ${_currentLocation!.altitude.toStringAsFixed(2)}m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _isCameraInitialized && _cameraService.cameras.length > 1
              ? FloatingActionButton(
                  onPressed: _switchCamera,
                  child: const Icon(Icons.cameraswitch),
                )
              : null,
    );
  }
}

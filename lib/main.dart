import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'jr_core/api/service.dart' as jr;

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
  late final jr.JRApiService? _jrApiService;

  bool _isCameraInitialized = false;
  int _currentCameraIndex = 0;
  ui.Image? _uiImage;

  final _gpsService = GPSService(const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
  ));
  bool _isGpsInitialized = false;
  Position? _currentLocation;

  static const int imageWidth = 1280;
  static const int imageHeight = 720;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _jrApiService = jr.JRApiService.init();
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
    if (location != null) {
      print("location: $location");
      setState(() {
        _currentLocation = location;
      });
    }

    _gpsService.getLocationStream().listen((location) {
      setState(() {
        _currentLocation = location;
      });
    });
  }

  Future<void> _initializeCamera() async {
    if (_jrApiService == null) return;

    try {
      print("Number of cameras: ${_jrApiService.numCameras}");

      final didOpen = _jrApiService.openCamera(
        imageWidth,
        imageHeight,
        _currentCameraIndex,
      );
      if (didOpen) {
        setState(() {
          _isCameraInitialized = didOpen;
        });
        _startCameraStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startCameraStream() {
    if (_jrApiService == null || !_isCameraInitialized) {
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

      setState(() {
        if (_uiImage != null) {
          _uiImage!.dispose();
        }
        _uiImage = uiImage;
      });
    });
  }

  Future<void> _switchCamera() async {
    if (_jrApiService == null) return;

    setState(() {
      _isCameraInitialized = false;
    });

    await _jrApiService.stopCameraStreaming();
    _jrApiService.closeCamera();

    _currentCameraIndex = (_currentCameraIndex + 1) % _jrApiService.numCameras;
    final didOpen =
        _jrApiService.openCamera(imageWidth, imageHeight, _currentCameraIndex);

    setState(() {
      _isCameraInitialized = didOpen;
    });

    if (_isCameraInitialized) {
      _startCameraStream();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final quarterTurns = orientation == Orientation.landscape
        ? 2
        : orientation == Orientation.portrait
            ? 1
            : 0;

    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized
              ? _uiImage != null
                  ? Center(
                      child: RotatedBox(
                        quarterTurns: quarterTurns,
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
          _isCameraInitialized && _jrApiService!.numCameras > 1
              ? FloatingActionButton(
                  onPressed: _switchCamera,
                  child: const Icon(Icons.cameraswitch),
                )
              : null,
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'jr_core/api/service.dart' as jr;

import 'gps/gps_service.dart';
import 'utils/image.dart';
import 'widget/image_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hide status bar and make app full screen
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
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
  MapController? _mapController;

  bool _isCameraInitialized = false;
  int _currentCameraIndex = 0;
  ui.Image? _uiImage;

  final _gpsService = GPSService(const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
  ));
  Position? _currentLocation;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  String _nextRoad = "Unknown Road";
  double _distanceToTurn = 0.5;
  double _distanceRemaining = 0.8;
  String _estimatedArrival = "";
  static const int _timeToArrival = 4;

  static const int imageWidth = 1280;
  static const int imageHeight = 720;

  @override
  void initState() {
    super.initState();
    _updateEstimatedArrival();
    _initializeServices();
  }

  void _updateEstimatedArrival() {
    final DateTime now = DateTime.now();
    final DateTime arrivalTime = now.add(const Duration(minutes: _timeToArrival));
    setState(() {
      _estimatedArrival = _formatTime(arrivalTime);
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  Future<void> _initializeServices() async {
    _jrApiService = jr.JRApiService.init();
    await _initializeCamera();
    await _initializeGPS();
  }

  Future<void> _initializeGPS() async {
    final gpsInitialized = await _gpsService.initialize();
    if (gpsInitialized) {
      await _startLocationUpdates();
    }
  }

  void _updateMapPosition(Position position) {
    _mapController?.move(
      LatLng(position.latitude, position.longitude),
      17,
    );
    
    // Update speed information
    double speedKmph = position.speed * 3.6; // Convert m/s to km/h
    setState(() {
      _currentSpeed = speedKmph;
      if (speedKmph > _maxSpeed) {
        _maxSpeed = speedKmph;
      }
      
      // Demo navigation data (would be replaced with real navigation data)
      _nextRoad = "Cabrillo Road";
      _distanceToTurn = 1.5;
      _distanceRemaining = 11.3;
      
      // Update estimated arrival time
      _updateEstimatedArrival();
    });
  }

  Future<void> _startLocationUpdates() async {
    await Future.delayed(const Duration(seconds: 1));

    final lastKnownLocation = await _gpsService.getLastKnownLocation();
    print("lastKnownLocation: $lastKnownLocation");
    setState(() {
      _currentLocation = lastKnownLocation;
    });
    if (lastKnownLocation != null && _mapController != null) {
      _updateMapPosition(lastKnownLocation);
    }

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
      if (_mapController != null) {
        _updateMapPosition(location);
      }
    }

    _gpsService.getLocationStream().listen((location) {
      setState(() {
        _currentLocation = location;
      });
      if (_mapController != null) {
        _updateMapPosition(location);
      }
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
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: isLandscape
          // Landscape orientation: side-by-side (left/right)
          ? Row(
              children: [
                // Camera view (left side)
                Expanded(child: _buildCameraView()),
                
                // Map view (right side)
                Expanded(child: _buildMapView()),
              ],
            )
          // Portrait orientation: stacked (top/bottom)
          : Column(
              children: [
                // Camera view (top)
                Expanded(child: _buildCameraView()),
                
                // Map view (bottom)
                Expanded(child: _buildMapView()),
              ],
            ),
      ),
    );
  }
  
  // Camera view widget
  Widget _buildCameraView() {
    final orientation = MediaQuery.of(context).orientation;
    
    return Stack(
      children: [
        // Camera background
        if (_isCameraInitialized && _uiImage != null)
          Positioned.fill(
            child: orientation == Orientation.portrait
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(3.14159265359 / 2), // 90 degrees in radians
                    child: CustomPaint(
                      painter: ImagePainter(
                        _uiImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: ImagePainter(
                      _uiImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
          )
        else
          const Center(child: CircularProgressIndicator()),
        
        // Current speed (top left corner)
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentSpeed.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'km/h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Camera index display
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Camera ${_currentCameraIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        // Camera switch button (top right corner)
        if (_isCameraInitialized && _jrApiService != null && _jrApiService.numCameras > 1)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Switch Camera',
              ),
            ),
          ),
      ],
    );
  }
  
  // Map view widget
  Widget _buildMapView() {
    return Stack(
      children: [
        // Map background
        Positioned.fill(
          child: _currentLocation != null
              ? FlutterMap(
                  mapController: _mapController ??= MapController(),
                  options: MapOptions(
                    initialCenter: LatLng(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                    ),
                    initialZoom: 17,
                    maxZoom: 19,
                    minZoom: 3,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.jeenrobotics.front',
                    ),
                    // Blue route line
                    const PolylineLayer(
                      polylines: [
                        /* Removed blue route line */
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Current location marker
                        Marker(
                          point: LatLng(
                            _currentLocation!.latitude,
                            _currentLocation!.longitude,
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.amber,
                            size: 30,
                          ),
                        ),
                        // Destination marker
                        Marker(
                          point: LatLng(
                            _currentLocation!.latitude + 0.003,
                            _currentLocation!.longitude + 0.002,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        
        // Top navigation bar
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.turn_right,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_distanceToTurn km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _nextRoad,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom ETA bar
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _estimatedArrival,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_timeToArrival min',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_distanceRemaining km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for the green road path overlay
class RoadPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.4)
      ..style = PaintingStyle.fill;
      
    final path = ui.Path();
    
    // Start at bottom-left corner
    path.moveTo(0, size.height);
    
    // Draw the left edge of the road
    path.lineTo(size.width * 0.3, size.height * 0.2);
    
    // Draw the right edge of the road
    path.lineTo(size.width * 0.8, size.height * 0.2);
    
    // Back to bottom-right corner
    path.lineTo(size.width, size.height);
    
    // Close the path
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw road boundary lines
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
      
    // Left boundary
    final leftPath = ui.Path();
    leftPath.moveTo(size.width * 0.3, size.height);
    leftPath.lineTo(size.width * 0.3, size.height * 0.2);
    canvas.drawPath(leftPath, linePaint);
    
    // Right boundary (red for warning)
    final rightPath = ui.Path();
    rightPath.moveTo(size.width * 0.7, size.height);
    rightPath.lineTo(size.width * 0.7, size.height * 0.2);
    
    final redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(rightPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

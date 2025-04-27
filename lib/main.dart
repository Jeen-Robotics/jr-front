import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'jr_core/api/service.dart' as jr;

import 'gps/gps_service.dart';
import 'widget/image_painter.dart';

import 'blocs/camera/bloc/camera_bloc.dart';
import 'blocs/camera/bloc/camera_event.dart';
import 'blocs/camera/bloc/camera_state.dart';
import 'blocs/location/bloc/location_bloc.dart';
import 'blocs/location/bloc/location_event.dart';
import 'blocs/location/bloc/location_state.dart';
import 'blocs/navigation/bloc/navigation_bloc.dart';
import 'blocs/navigation/bloc/navigation_event.dart';
import 'blocs/navigation/bloc/navigation_state.dart';

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
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _jrApiService = jr.JRApiService.init();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CameraBloc>(
          create: (context) =>
              CameraBloc(_jrApiService)..add(const CameraInitialize()),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(
            GPSService(const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
            )),
          )..add(LocationInitialize()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc()..add(NavigationInitialize()),
        ),
      ],
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              final orientation = MediaQuery.of(context).orientation;
              final isLandscape = orientation == Orientation.landscape;

              return isLandscape
                  // Landscape orientation: side-by-side (left/right)
                  ? Row(
                      children: [
                        // Camera view (left side)
                        Expanded(child: _buildCameraView()),

                        // Map view (right side)
                        Expanded(
                          child: _buildMapView(_mapController, locationState),
                        ),
                      ],
                    )
                  // Portrait orientation: stacked (top/bottom)
                  : Column(
                      children: [
                        // Camera view (top)
                        Expanded(child: _buildCameraView()),

                        // Map view (bottom)
                        Expanded(
                          child: _buildMapView(_mapController, locationState),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  // Camera view widget
  Widget _buildCameraView() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, cameraState) {
        final orientation = MediaQuery.of(context).orientation;

        return Stack(
          children: [
            // Camera background
            if (cameraState.isInitialized && cameraState.uiImage != null)
              Positioned.fill(
                child: orientation == Orientation.portrait
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(
                          3.14159265359 / 2,
                        ), // 90 degrees in radians
                        child: CustomPaint(
                          painter: ImagePainter(
                            cameraState.uiImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: ImagePainter(
                          cameraState.uiImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Current speed (top left corner)
            BlocBuilder<LocationBloc, LocationState>(
              builder: (context, locationState) {
                return Positioned(
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
                          '${locationState.currentSpeed.toInt()}',
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
                );
              },
            ),

            // Camera index display
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Camera ${cameraState.currentCameraIndex + 1}',
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
            if (cameraState.isInitialized && cameraState.numCameras > 1)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.read<CameraBloc>().add(CameraSwitch());
                    },
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
      },
    );
  }

  // Map view widget
  Widget _buildMapView(
      MapController mapController, LocationState locationState) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navigationState) {
        return Stack(
          children: [
            // Map background
            Positioned.fill(
              child: locationState.currentLocation != null
                  ? FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: locationState.mapCenter ??
                            LatLng(
                              locationState.currentLocation!.latitude,
                              locationState.currentLocation!.longitude,
                            ),
                        initialZoom: 17,
                        maxZoom: 19,
                        minZoom: 3,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                              point: locationState.mapCenter ??
                                  LatLng(
                                    locationState.currentLocation!.latitude,
                                    locationState.currentLocation!.longitude,
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
                                locationState.currentLocation!.latitude + 0.003,
                                locationState.currentLocation!.longitude +
                                    0.002,
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
                            '${navigationState.distanceToTurn} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            navigationState.nextRoad,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      navigationState.estimatedArrival,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${navigationState.timeToArrival} min',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${navigationState.distanceRemaining} km',
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
      },
    );
  }
}

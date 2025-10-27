import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'jr_core/api/service.dart' as jr;

import 'blocs/camera/bloc/camera_bloc.dart';
import 'blocs/camera/bloc/camera_event.dart';
import 'blocs/route/bloc/route_bloc.dart';
import 'blocs/route/bloc/route_event.dart';
import 'widget/camera_view.dart';
import 'widget/map_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Request camera permission
  final cameraStatus = await Permission.camera.request();
  if (cameraStatus.isDenied) {
    // Handle the case where user denied the permission
    // You might want to show a dialog explaining why the permission is needed
    return;
  }

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
  bool _isRecording = false;
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CameraBloc>(
          create: (context) =>
              CameraBloc(_jrApiService)..add(const CameraInitialize()),
        ),
        BlocProvider<RouteBloc>(
          create: (context) => RouteBloc()
            ..add(const RouteInitialize())
            ..add(const RouteStartLocationUpdates()),
        ),
      ],
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Flex(
            direction: isLandscape ? Axis.horizontal : Axis.vertical,
            children: const [
              Expanded(child: CameraView()),
              Expanded(child: MapView()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
            child: Icon(
              _isRecording ? Icons.stop : Icons.fiber_manual_record,
              color: Colors.white,
            ),
            onPressed: () {
              if (_jrApiService == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Service not initialized"),
                ));
                return;
              }

              if (_isRecording) {
                _jrApiService.stopRecording();
                setState(() {
                  _isRecording = false;
                });
              } else {
                _jrApiService.startRecording();
                setState(() {
                  _isRecording = true;
                });
              }
            }),
      ),
    );
  }
}

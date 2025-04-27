import 'dart:async';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'route_event.dart';
import 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final MapController mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _navigationTimer;

  RouteBloc() : super(const RouteState()) {
    on<RouteInitialize>(_onInitialize);
    on<RouteStartLocationUpdates>(_onStartLocationUpdates);
    on<RouteLocationReceived>(_onLocationReceived);
    on<RouteUpdateTime>(_onUpdateTime);
  }

  Future<void> _onInitialize(
    RouteInitialize event,
    Emitter<RouteState> emit,
  ) async {
    final hasPermission = await _handleLocationPermission();
    if (hasPermission) {
      emit(state.copyWith(isInitialized: true));
    }
  }

  Future<void> _onStartLocationUpdates(
    RouteStartLocationUpdates event,
    Emitter<RouteState> emit,
  ) async {
    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      add(RouteLocationReceived(lastKnownPosition, isFirstLocation: true));
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((Position position) {
      add(RouteLocationReceived(position));
    });

    // Start navigation timer
    _navigationTimer?.cancel();
    _navigationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(RouteUpdateTime());
    });
  }

  void _onLocationReceived(
    RouteLocationReceived event,
    Emitter<RouteState> emit,
  ) {
    final position = event.position;
    final currentSpeed = position.speed;
    final maxSpeed = state.maxSpeed > currentSpeed ? state.maxSpeed : currentSpeed;
    final currentHeading = position.heading;

    if (!event.isFirstLocation) {
      mapController.rotate(currentHeading);
      mapController.move(
        LatLng(position.latitude, position.longitude),
        mapController.camera.zoom,
        offset: const Offset(0, 100),
      );
    }

    emit(state.copyWith(
      currentLocation: position,
      currentSpeed: currentSpeed,
      maxSpeed: maxSpeed,
      currentHeading: currentHeading,
    ));
  }

  void _onUpdateTime(
    RouteUpdateTime event,
    Emitter<RouteState> emit,
  ) {
    emit(state.copyWith(
      estimatedArrival: _calculateEstimatedArrival(state.timeToArrival),
    ));
  }

  String _calculateEstimatedArrival(int minutes) {
    final now = DateTime.now();
    final arrivalTime = now.add(Duration(minutes: minutes));
    return '${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    _navigationTimer?.cancel();
    return super.close();
  }
} 
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'route_event.dart';
import 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _navigationTimer;

  RouteBloc() : super(const RouteState()) {
    on<RouteInitialize>(_onInitialize);
    on<RouteStartLocationUpdates>(_onStartLocationUpdates);
    on<RouteLocationReceived>(_onLocationReceived);
    on<RouteUpdateTime>(_onUpdateTime);
    on<RouteMapControllerReady>(_onMapControllerReady);
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    add(const RouteMapControllerReady());
  }

  Future<void> _onMapControllerReady(
    RouteMapControllerReady event,
    Emitter<RouteState> emit,
  ) async {
    if (state.currentLocation != null) {
      final cameraPosition = _updateCameraPosition(
        LatLng(
          state.currentLocation!.latitude,
          state.currentLocation!.longitude,
        ),
        state.currentHeading,
      );

      // Update state with new camera position
      emit(state.copyWith(
        cameraPosition: cameraPosition,
      ));
    }
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
      add(const RouteUpdateTime());
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

    LatLng? cameraPosition;
    if (!event.isFirstLocation && _mapController != null) {
      cameraPosition = _updateCameraPosition(
        LatLng(position.latitude, position.longitude),
        currentHeading,
      );
    }

    emit(state.copyWith(
      currentLocation: position,
      currentSpeed: currentSpeed,
      maxSpeed: maxSpeed,
      currentHeading: currentHeading,
      cameraPosition: cameraPosition,
    ));
  }

  LatLng? _updateCameraPosition(LatLng position, double heading) {
    if (_mapController == null) return null;

    // Calculate camera position for third-person view
    const distance = 0.0005; // Distance behind the vehicle
    
    // Calculate the position behind the vehicle based on heading
    final radians = heading * (math.pi / 180);
    return LatLng(
      position.latitude + distance * math.cos(radians),
      position.longitude + distance * math.sin(radians),
    );
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
    _mapController?.dispose();
    return super.close();
  }
} 
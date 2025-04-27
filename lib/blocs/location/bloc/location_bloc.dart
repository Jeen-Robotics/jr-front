import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:jr_front/gps/gps_service.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GPSService _gpsService;
  StreamSubscription<Position>? _locationSubscription;

  LocationBloc(this._gpsService) : super(const LocationState()) {
    on<LocationInitialize>(_onLocationInitialize);
    on<LocationStartUpdates>(_onLocationStartUpdates);
    on<LocationReceived>(_onLocationReceived);
  }

  Future<void> _onLocationInitialize(
    LocationInitialize event,
    Emitter<LocationState> emit,
  ) async {
    final gpsInitialized = await _gpsService.initialize();
    emit(state.copyWith(isInitialized: gpsInitialized));
    
    if (gpsInitialized) {
      add(LocationStartUpdates());
    }
  }

  Future<void> _onLocationStartUpdates(
    LocationStartUpdates event,
    Emitter<LocationState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final lastKnownLocation = await _gpsService.getLastKnownLocation();
      if (lastKnownLocation != null) {
        emit(state.copyWith(
          currentLocation: lastKnownLocation,
          mapCenter: LatLng(
            lastKnownLocation.latitude,
            lastKnownLocation.longitude,
          ),
        ));
      }

      final location = await _gpsService.getCurrentLocation(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (location != null) {
        _updateLocationState(location, emit);
      }

      await _locationSubscription?.cancel();
      _locationSubscription = _gpsService.getLocationStream().listen((location) {
        add(LocationReceived(location));
      });
    } catch (e) {
      print('Error getting location updates: $e');
    }
  }

  void _onLocationReceived(
    LocationReceived event,
    Emitter<LocationState> emit,
  ) {
    _updateLocationState(event.position, emit);
  }

  void _updateLocationState(Position position, Emitter<LocationState> emit) {
    double speedKmph = position.speed * 3.6; // Convert m/s to km/h
    
    double newMaxSpeed = state.maxSpeed;
    if (speedKmph > state.maxSpeed) {
      newMaxSpeed = speedKmph;
    }
    
    emit(state.copyWith(
      currentLocation: position,
      mapCenter: LatLng(position.latitude, position.longitude),
      currentSpeed: speedKmph,
      maxSpeed: newMaxSpeed,
    ));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
} 
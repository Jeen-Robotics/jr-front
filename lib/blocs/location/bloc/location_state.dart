import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationState extends Equatable {
  final bool isInitialized;
  final Position? currentLocation;
  final double currentSpeed;
  final double maxSpeed;
  final LatLng? mapCenter;

  const LocationState({
    this.isInitialized = false,
    this.currentLocation,
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.mapCenter,
  });

  LocationState copyWith({
    bool? isInitialized,
    Position? currentLocation,
    double? currentSpeed,
    double? maxSpeed,
    LatLng? mapCenter,
  }) {
    return LocationState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      mapCenter: mapCenter ?? this.mapCenter,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        currentLocation,
        currentSpeed,
        maxSpeed,
        mapCenter,
      ];
} 
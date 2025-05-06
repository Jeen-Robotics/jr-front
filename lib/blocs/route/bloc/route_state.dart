import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteState extends Equatable {
  // Location-related state
  final bool isInitialized;
  final Position? currentLocation;
  final double currentSpeed;
  final double maxSpeed;
  final double currentHeading;

  // Camera-related state
  final LatLng? cameraPosition;
  final double cameraZoom;
  final double cameraTilt;
  final double cameraBearing;

  // Navigation-related state
  final String nextRoad;
  final double distanceToTurn;
  final double distanceRemaining;
  final String estimatedArrival;
  final int timeToArrival;

  const RouteState({
    // Location state
    this.isInitialized = false,
    this.currentLocation,
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.currentHeading = 0.0,
    // Camera state
    this.cameraPosition,
    this.cameraZoom = 17.0,
    this.cameraTilt = 45.0,
    this.cameraBearing = 0.0,
    // Navigation state
    this.nextRoad = "Unknown Road",
    this.distanceToTurn = 0.5,
    this.distanceRemaining = 0.8,
    this.estimatedArrival = "",
    this.timeToArrival = 4,
  });

  RouteState copyWith({
    // Location state
    bool? isInitialized,
    Position? currentLocation,
    double? currentSpeed,
    double? maxSpeed,
    double? currentHeading,
    // Camera state
    LatLng? cameraPosition,
    double? cameraZoom,
    double? cameraTilt,
    double? cameraBearing,
    // Navigation state
    String? nextRoad,
    double? distanceToTurn,
    double? distanceRemaining,
    String? estimatedArrival,
    int? timeToArrival,
  }) {
    return RouteState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      currentHeading: currentHeading ?? this.currentHeading,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      cameraZoom: cameraZoom ?? this.cameraZoom,
      cameraTilt: cameraTilt ?? this.cameraTilt,
      cameraBearing: cameraBearing ?? this.cameraBearing,
      nextRoad: nextRoad ?? this.nextRoad,
      distanceToTurn: distanceToTurn ?? this.distanceToTurn,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      timeToArrival: timeToArrival ?? this.timeToArrival,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        currentLocation,
        currentSpeed,
        maxSpeed,
        currentHeading,
        cameraPosition,
        cameraZoom,
        cameraTilt,
        cameraBearing,
        nextRoad,
        distanceToTurn,
        distanceRemaining,
        estimatedArrival,
        timeToArrival,
      ];
} 
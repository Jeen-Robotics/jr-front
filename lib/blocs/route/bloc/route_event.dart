import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

// Location-related events
class RouteInitialize extends RouteEvent {}

class RouteStartLocationUpdates extends RouteEvent {}

class RouteLocationReceived extends RouteEvent {
  final Position position;
  final bool isFirstLocation;

  const RouteLocationReceived(this.position, {this.isFirstLocation = false});

  @override
  List<Object?> get props => [position, isFirstLocation];
}

// Navigation-related events
class RouteUpdateTime extends RouteEvent {} 
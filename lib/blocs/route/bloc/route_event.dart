import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

// Location-related events
class RouteInitialize extends RouteEvent {
  const RouteInitialize();
}

class RouteStartLocationUpdates extends RouteEvent {
  const RouteStartLocationUpdates();
}

class RouteLocationReceived extends RouteEvent {
  final Position position;
  final bool isFirstLocation;

  const RouteLocationReceived(this.position, {this.isFirstLocation = false});

  @override
  List<Object?> get props => [position, isFirstLocation];
}

// Navigation-related events
class RouteUpdateTime extends RouteEvent {
  const RouteUpdateTime();
}

class RouteMapControllerReady extends RouteEvent {
  const RouteMapControllerReady();
} 
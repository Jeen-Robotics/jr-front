import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LocationInitialize extends LocationEvent {}

class LocationStartUpdates extends LocationEvent {}

class LocationReceived extends LocationEvent {
  final Position position;

  const LocationReceived(this.position);

  @override
  List<Object?> get props => [position];
} 
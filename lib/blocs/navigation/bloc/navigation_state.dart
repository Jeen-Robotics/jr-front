import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final String nextRoad;
  final double distanceToTurn;
  final double distanceRemaining;
  final String estimatedArrival;
  final int timeToArrival;

  const NavigationState({
    this.nextRoad = "Unknown Road",
    this.distanceToTurn = 0.5,
    this.distanceRemaining = 0.8,
    this.estimatedArrival = "",
    this.timeToArrival = 4,
  });

  NavigationState copyWith({
    String? nextRoad,
    double? distanceToTurn,
    double? distanceRemaining,
    String? estimatedArrival,
    int? timeToArrival,
  }) {
    return NavigationState(
      nextRoad: nextRoad ?? this.nextRoad,
      distanceToTurn: distanceToTurn ?? this.distanceToTurn,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      timeToArrival: timeToArrival ?? this.timeToArrival,
    );
  }

  @override
  List<Object?> get props => [
        nextRoad,
        distanceToTurn,
        distanceRemaining,
        estimatedArrival,
        timeToArrival,
      ];
} 
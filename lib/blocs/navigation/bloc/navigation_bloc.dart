import 'package:bloc/bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationInitialize>(_onNavigationInitialize);
    on<NavigationUpdateTime>(_onNavigationUpdateTime);
  }

  void _onNavigationInitialize(
    NavigationInitialize event,
    Emitter<NavigationState> emit,
  ) {
    _updateEstimatedArrival(emit);
  }

  void _onNavigationUpdateTime(
    NavigationUpdateTime event,
    Emitter<NavigationState> emit,
  ) {
    _updateEstimatedArrival(emit);

    // Demo navigation data (would be replaced with real navigation data)
    emit(state.copyWith(
      nextRoad: "Cabrillo Road",
      distanceToTurn: 1.5,
      distanceRemaining: 11.3,
    ));
  }

  void _updateEstimatedArrival(Emitter<NavigationState> emit) {
    final DateTime now = DateTime.now();
    final DateTime arrivalTime = now.add(Duration(minutes: state.timeToArrival));
    emit(state.copyWith(
      estimatedArrival: _formatTime(arrivalTime),
    ));
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }
} 
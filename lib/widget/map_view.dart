import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../blocs/route/bloc/route_bloc.dart';
import '../blocs/route/bloc/route_state.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RouteBloc>();

    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, routeState) {
        return Stack(
          children: [
            // Map background
            Positioned.fill(
              child: routeState.currentLocation != null
                  ? FlutterMap(
                      mapController: bloc.mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          routeState.currentLocation!.latitude,
                          routeState.currentLocation!.longitude,
                        ),
                        initialZoom: 17,
                        maxZoom: 19,
                        minZoom: 3,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.jeenrobotics.front',
                        ),
                        // Blue route line
                        const PolylineLayer(
                          polylines: [
                            /* Removed blue route line */
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Current location marker
                            Marker(
                              point: LatLng(
                                routeState.currentLocation!.latitude,
                                routeState.currentLocation!.longitude,
                              ),
                              child: Transform.rotate(
                                angle:
                                    -routeState.currentHeading * (3.14159 / 180),
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.amber,
                                  size: 30,
                                ),
                              ),
                            ),
                            // Destination marker
                            Marker(
                              point: LatLng(
                                routeState.currentLocation!.latitude + 0.003,
                                routeState.currentLocation!.longitude + 0.002,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // Top navigation bar
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.turn_right,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${routeState.distanceToTurn} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            routeState.nextRoad,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom ETA bar
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ETA: ${routeState.estimatedArrival}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${routeState.timeToArrival} min',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${routeState.distanceRemaining} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

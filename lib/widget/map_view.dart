import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/route/bloc/route_bloc.dart';
import '../blocs/route/bloc/route_state.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, routeState) {
        if (routeState.currentLocation == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentPosition = LatLng(
          routeState.currentLocation!.latitude,
          routeState.currentLocation!.longitude,
        );

        // Update markers
        final markers = {
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(
              routeState.currentLocation!.latitude + 0.003,
              routeState.currentLocation!.longitude + 0.002,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };

        // Update camera position for third-person view
        if (_mapController != null && routeState.cameraPosition != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: routeState.cameraPosition!,
                zoom: routeState.cameraZoom,
                tilt: routeState.cameraTilt,
                bearing: routeState.cameraBearing,
              ),
            ),
          );
        }

        return Stack(
          children: [
            // Map background
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  context.read<RouteBloc>().setMapController(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: currentPosition,
                  zoom: 17,
                  tilt: 45, // 3D view tilt
                  bearing: routeState.currentHeading,
                ),
                markers: markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                trafficEnabled: true,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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

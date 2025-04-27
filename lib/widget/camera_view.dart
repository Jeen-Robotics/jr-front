import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/camera/bloc/camera_bloc.dart';
import '../blocs/camera/bloc/camera_event.dart';
import '../blocs/camera/bloc/camera_state.dart';
import '../blocs/route/bloc/route_bloc.dart';
import '../blocs/route/bloc/route_state.dart';
import '../widget/image_painter.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, cameraState) {
        final orientation = MediaQuery.of(context).orientation;

        return Stack(
          children: [
            // Camera background
            if (cameraState.isInitialized && cameraState.uiImage != null)
              Positioned.fill(
                child: orientation == Orientation.portrait
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(
                          3.14159265359 / 2,
                        ), // 90 degrees in radians
                        child: CustomPaint(
                          painter: ImagePainter(
                            cameraState.uiImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: ImagePainter(
                          cameraState.uiImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Current speed (top left corner)
            BlocSelector<RouteBloc, RouteState, double>(
              selector: (state) => state.currentSpeed,
              builder: (context, currentSpeed) {
                return Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${currentSpeed.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'km/h',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Camera index display
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Camera ${cameraState.currentCameraIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Camera switch button (top right corner)
            if (cameraState.isInitialized && cameraState.numCameras > 1)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.read<CameraBloc>().add(CameraSwitch());
                    },
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Switch Camera',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
} 
import 'package:geolocator/geolocator.dart';

final class GPSService {
  final LocationSettings locationSettings;

  GPSService(this.locationSettings);

  /// Initialize the GPS service and request necessary permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return false;
      }

      return true;
    } catch (e) {
      print('Error initializing GPS: $e');
      return false;
    }
  }

  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  /// Get the current location
  Future<Position?> getCurrentLocation({
    LocationSettings? locationSettings,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings ?? this.locationSettings,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Start listening to location updates
  Stream<Position> getLocationStream({LocationSettings? locationSettings}) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ?? this.locationSettings,
    ).handleError((error) {
      print('Location stream error: $error');
    });
  }
}

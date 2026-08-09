import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? errorMessage;
  final bool isSuccess;

  LocationResult({
    this.latitude,
    this.longitude,
    this.errorMessage,
    required this.isSuccess,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          isSuccess: false,
          errorMessage: 'Location services are disabled. Please enable them.',
        );
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            isSuccess: false,
            errorMessage: 'Location permissions are denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          isSuccess: false,
          errorMessage: 'Location permissions are permanently denied, we cannot request permissions. Please enable in settings.',
        );
      }

      // When we reach here, permissions are granted and we can continue accessing the position of the device.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      return LocationResult(
        isSuccess: true,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return LocationResult(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred while fetching location.',
      );
    }
  }
}

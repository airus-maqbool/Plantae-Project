import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();

    // First time or previously denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is denied forever
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings(); // Redirect to settings
      return null;
    }

    // Permission granted
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    return null;
  }
}

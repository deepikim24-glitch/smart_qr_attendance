import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_qr_attendance/core/errors/exceptions.dart';

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationService {
  Future<GeoPoint> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const ApiException(
        'Location services are disabled. Enable GPS and try again.',
        code: 'GPS_DISABLED',
      );
    }

    final permission = await Permission.locationWhenInUse.request();
    if (permission.isPermanentlyDenied || permission.isDenied) {
      throw const ApiException(
        'Location permission was denied. Allow location access to mark attendance.',
        code: 'GPS_DENIED',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(position.latitude, position.longitude);
  }
}

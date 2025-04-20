import 'dart:async';
import '../services/location_service.dart';
import '../services/supabase_service.dart';

class LocationScheduler {
  static Timer? _timer;

  static void startLocationUpdates() {
    // Trigger immediately once when started
    print("In location utility");
    _updateLocation();

    // Then every 1 hour (3600 seconds)
    _timer = Timer.periodic(Duration(hours: 1), (Timer timer) {
      _updateLocation();
    });
  }

  static void stopLocationUpdates() {
    _timer?.cancel();
  }

  static Future<void> _updateLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      await SupabaseService.saveLocation(position.latitude, position.longitude);
      print('Location updated to Supabase at ${DateTime.now()}');
    } catch (e) {
      print('Error updating location: $e');
    }
  }
}

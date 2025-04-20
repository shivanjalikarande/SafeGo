import '../../supabase_client.dart';

class SupabaseService {
  static Future<void> saveLocation(double latitude, double longitude) async {
    final user = supabase.auth.currentUser;
    
    print(user);
    if (user == null) {
      throw Exception('User not logged in.');
    }
    try{
      final response = await supabase.from('locations').insert({
      'user_id': user.id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
     if (response.error != null) {
      throw Exception('Failed to save location: ${response.error!.message}');
    }

    // No need to check response.error — supabase.dart throws exceptions
    print('Location saved for ${user.email}');

    } catch(e){
      print(e);
    }
    
  }
}

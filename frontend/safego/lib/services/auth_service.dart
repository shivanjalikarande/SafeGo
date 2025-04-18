import '../services/secure_storage_service.dart'; // token storage
import '../utils/jwt_utils.dart'; // JWT Utils
import '../supabase_client.dart'; // Import your supabase client instance

class AuthService {
  // Check if the session is valid and refresh if necessary
  static Future<bool> checkAndRefreshSession() async {
    // Get token from secure storage
    final token = await SecureStorageService.getToken();
    print('Stored Token: $token');
    if (token == null) return false;  // No token, user is not logged in

    // Check if token is expired
    if (JwtUtils.isTokenExpired(token)) {
      try {
        // Try refreshing the session using Supabase client
        final res = await supabase.auth.refreshSession();

        final newToken = res.session?.accessToken;

        if (newToken != null) {
          // Save the new token in secure storage
          await SecureStorageService.saveToken(newToken);
          return true;  // Successfully refreshed session
        } else {
          await SecureStorageService.clear();  // Clear storage if refresh fails
          return false;
        }
      } catch (e) {
        // Handle error if refreshing session fails (expired refresh token)
        await SecureStorageService.clear();  // Clear storage on failure
        return false;  // Failed refresh, need to log in again
      }
    }

    return true;  // Valid token, user is logged in
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  // Write data
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all data
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Get the token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // Save the token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }
}

import 'package:jwt_decoder/jwt_decoder.dart';

class JwtUtils {
  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}

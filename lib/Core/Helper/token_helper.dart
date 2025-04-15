import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'token';
  static final _storage = FlutterSecureStorage();

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  // Delete token
  static Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}

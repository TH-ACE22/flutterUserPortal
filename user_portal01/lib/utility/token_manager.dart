import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _refreshUrl = 'http://10.0.2.2:8081/auth/refresh';

  static Future<String?> getAccessToken() => _storage.read(key: 'jwt_token');
  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  static Future<void> storeTokens(String access, String refresh) async {
    await _storage.write(key: 'jwt_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse(_refreshUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'refreshToken': refreshToken}, //  send as form field
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storeTokens(data['token'], data['refreshToken']);
      return true;
    }

    return false;
  }
}

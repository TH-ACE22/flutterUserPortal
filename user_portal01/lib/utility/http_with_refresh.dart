import 'package:http/http.dart' as http;
import 'token_manager.dart';

class HttpWithRefresh {
  static Future<http.Response> get(Uri uri) async {
    final token = await TokenManager.getAccessToken();
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 401) {
      final refreshed = await TokenManager.refreshAccessToken();
      if (refreshed) {
        final newToken = await TokenManager.getAccessToken();
        return http.get(uri, headers: {
          'Authorization': 'Bearer $newToken',
          'Content-Type': 'application/json'
        });
      }
    }

    return response;
  }

  static Future<http.Response> post(Uri uri) async {
    final token = await TokenManager.getAccessToken();
    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 401) {
      final refreshed = await TokenManager.refreshAccessToken();
      if (refreshed) {
        final newToken = await TokenManager.getAccessToken();
        return http.post(uri, headers: {
          'Authorization': 'Bearer $newToken',
          'Content-Type': 'application/json'
        });
      }
    }

    return response;
  }
}

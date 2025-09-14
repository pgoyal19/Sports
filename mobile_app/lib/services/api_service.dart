import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_service.dart';

class ApiService {
  // Optional override for physical devices on LAN
  static String? _overrideBaseUrl;

  static void setBaseUrl(String url) {
    _overrideBaseUrl = url;
  }

  static String get _baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (Platform.isAndroid) {
      // Android emulator special alias for host machine
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static Future<bool> loginUser(String email, String password) async {
    var response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode != 200) return false;
    final data = jsonDecode(response.body);
    return data["success"] == true;
  }

  static Future<Map<String, dynamic>> uploadVideo(String path) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_video/'));
    request.files.add(await http.MultipartFile.fromPath('file', path));
    
    // Add authentication headers
    request.headers.addAll(AuthService.getAuthHeaders());
    
    var res = await request.send();
    var responseData = await res.stream.bytesToString();
    final json = jsonDecode(responseData);
    // Backend returns flat JSON { score, cheat_detected }
    return json is Map<String, dynamic> ? json : {"score": 0.0, "cheat_detected": 0};
  }

  static Future<Map<String, dynamic>> fetchLatestResult() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/results/latest'),
      headers: AuthService.getAuthHeaders(),
    );
    if (res.statusCode != 200) return {"score": 0.0, "cheat_detected": 0};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> fetchLeaderboard() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/results/leaderboard'),
      headers: AuthService.getAuthHeaders(),
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      return data['items'] as List<dynamic>;
    }
    return [];
  }
}

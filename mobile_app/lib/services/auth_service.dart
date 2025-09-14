import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static String? _baseUrl;
  static String? _authToken;
  static String? _phoneNumber;

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static String get baseUrl {
    if (_baseUrl != null && _baseUrl!.isNotEmpty) {
      return _baseUrl!;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static bool get isAuthenticated => _authToken != null;

  static String? get authToken => _authToken;

  static String? get phoneNumber => _phoneNumber;

  // Send OTP to phone number
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _phoneNumber = phoneNumber;
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'];
        _phoneNumber = phoneNumber;
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'token': _authToken,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    return await sendOTP(phoneNumber);
  }

  // Logout
  static Future<void> logout() async {
    _authToken = null;
    _phoneNumber = null;
  }

  // Get authenticated headers
  static Map<String, String> getAuthHeaders() {
    if (_authToken == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Check if token is valid (basic check)
  static bool isTokenValid() {
    return _authToken != null && _authToken!.isNotEmpty;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Chrome/Web, localhost works. For Android Emulator use '10.0.2.2'.
  // If you are testing on a real device, use your PC's LAN IP.
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>?> loginOrSignup(String nickname) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': nickname}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Get Profile Error: $e');
    }
    return null;
  }
}

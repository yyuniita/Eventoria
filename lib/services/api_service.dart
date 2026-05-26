import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Ganti IP sesuai kondisi:
  // - Emulator Android  → 10.0.2.2
  // - HP fisik          → IP komputer kamu (cek dengan `ipconfig` / `ifconfig`)
  // - iOS Simulator     → 127.0.0.1 (boleh)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  // ✅ checkEmailExists dihapus — tidak perlu endpoint khusus.
  // Laravel sudah otomatis menolak email duplikat lewat response register.

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> me() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<void> logout() async {
    final headers = await getHeaders();
    await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
    await removeToken();
  }
}
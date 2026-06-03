import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventoria/models/user_model.dart';

class AuthService {
  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyUser = 'user_data';

  // Simpan data user setelah login (panggil ini setelah dapat response API)
  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, user.token ?? '');
    await prefs.setString(_keyRole, user.role == UserRole.organizer ? 'organizer' : 'user');
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // Ambil user yang sedang login
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_keyUser);
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  // Ambil token saja
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Ambil role saja
  static Future<UserRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyRole);
    if (role == null) return null;
    return role == 'organizer' ? UserRole.organizer : UserRole.user;
  }

  // Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout: hapus semua data session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUser);
  }
}
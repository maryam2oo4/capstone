import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dio = await ApiClient.instance.dio();
    final res = await dio.post(
      '/api/mobile/login',
      data: {'email': email, 'password': password},
    );

    final token = res.data['token'] as String?;
    final user = res.data['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty || user == null) {
      throw Exception('Invalid server response');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', (user['role'] ?? '').toString());
    await prefs.setString('user_email', (user['email'] ?? '').toString());

    return {'token': token, 'user': user};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
  }

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}


import 'api_client.dart';

class PublicService {
  static Future<Map<String, dynamic>> getSystemSettings() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/system-settings');
    return response.data;
  }

  static Future<Map<String, dynamic>> getDonationStats() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/public/donation-stats');
    return response.data;
  }

  /// Fetches hospitals from backend. Returns either:
  /// - Map with 'hospitals' key: {hospitals: [...], total: n}
  /// - Direct List of hospital objects
  static Future<dynamic> getHospitals() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/hospital');
    return response.data;
  }

  static Future<Map<String, dynamic>> getArticles() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/articles');
    return response.data;
  }

  static Future<Map<String, dynamic>> getArticleDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/articles/$id');
    return response.data;
  }

  static Future<Map<String, dynamic>> checkEmail(String email) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/email/check?email=$email');
    return response.data;
  }

  static Future<Map<String, dynamic>> testConnection() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/test');
    return response.data;
  }
}

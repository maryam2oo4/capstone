import 'package:dio/dio.dart';
import 'api_client.dart';

class SettingsService {
  static Future<Map<String, dynamic>> getAllSettings() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/settings/all');
    return response.data;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/settings/profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('/settings/profile', data: profileData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getMedicalInfo() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/settings/medical');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateMedicalInfo(Map<String, dynamic> medicalData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('/settings/medical', data: medicalData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> passwordData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('/settings/password', data: passwordData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/settings/notifications');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateNotificationSettings(Map<String, dynamic> notificationData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('/settings/notifications', data: notificationData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getCommunicationPreferences() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/settings/communication');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateCommunicationPreferences(Map<String, dynamic> communicationData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('/settings/communication', data: communicationData);
    return response.data;
  }

  static Future<void> deleteAccount() async {
    final dio = await ApiClient.instance.dio();
    await dio.delete('/settings/account');
  }
}

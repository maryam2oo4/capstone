import 'package:dio/dio.dart';
import 'api_client.dart';

class FinancialService {
  static Future<Map<String, dynamic>> submitDonation(Map<String, dynamic> donationData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/financial-donations',
      data: donationData,
      options: Options(
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> getDonations() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/financial-donations');
    return response.data;
  }

  static Future<Map<String, dynamic>> getDonationDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/financial-donations/$id');
    return response.data;
  }

  static Future<Map<String, dynamic>> getPatientCases() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/patient-cases');
    return response.data;
  }

  static Future<Map<String, dynamic>> getPatientCaseDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/patient-cases/$id');
    return response.data;
  }
}

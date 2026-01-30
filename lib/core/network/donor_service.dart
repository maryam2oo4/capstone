import 'package:dio/dio.dart';
import 'api_client.dart';

class DonorService {
  static const String _prefix = '/donor';

  static Future<Map<String, dynamic>> getDashboard() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('$_prefix/dashboard');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMyDonations() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('$_prefix/my-donations');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMyAppointments() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('$_prefix/my-appointments');
    return response.data;
  }

  static Future<Map<String, dynamic>> chooseLivingDonorAppointment(String code, Map<String, dynamic> appointmentData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post('$_prefix/living-donors/$code/choose-appointment', data: appointmentData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getCertificates() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('$_prefix/certificates');
    return response.data;
  }

  static Future<Response> downloadCertificate(int id) async {
    final dio = await ApiClient.instance.dio();
    return await dio.get('$_prefix/certificates/$id/download', options: Options(responseType: ResponseType.bytes));
  }

  static Future<Map<String, dynamic>> getHomeAppointmentRating(int homeAppointmentId) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('$_prefix/home-appointments/$homeAppointmentId/rating');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateHomeAppointmentRating(int homeAppointmentId, Map<String, dynamic> ratingData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.put('$_prefix/home-appointments/$homeAppointmentId/rating', data: ratingData);
    return response.data;
  }
}

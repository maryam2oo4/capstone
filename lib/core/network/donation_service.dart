import 'package:dio/dio.dart';
import 'api_client.dart';

class DonationService {
  static Future<Map<String, dynamic>> getHomeDonations() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood/home_donation');
    return response.data;
  }

  static Future<Map<String, dynamic>> getHomeDonationDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood/home_donation/$id');
    return response.data;
  }

  static Future<Map<String, dynamic>> createHomeAppointment(Map<String, dynamic> appointmentData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/blood/home_appointment',
      data: appointmentData,
      options: Options(
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> getHospitalDonations() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood/hospital_donation');
    return response.data;
  }

  static Future<Map<String, dynamic>> getHospitalDonationDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood/hospital_donation/$id');
    return response.data;
  }

  static Future<Map<String, dynamic>> createHospitalAppointment(Map<String, dynamic> appointmentData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/hospital/appointments',
      data: appointmentData,
      options: Options(
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> getBloodTypes() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood-types');
    return response.data;
  }

  static Future<Map<String, dynamic>> getHospitals() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/hospital');
    return response.data;
  }

  static Future<Map<String, dynamic>> getHospitalDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/hospital/$id');
    return response.data;
  }
}

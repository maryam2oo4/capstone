import 'package:dio/dio.dart';
import 'api_client.dart';

/// Extended timeouts for organ donation - backend does DB write + email sending
/// which can exceed default 60s receive timeout, especially on cold starts.
const _organDonationSendTimeout = Duration(seconds: 90);
const _organDonationReceiveTimeout = Duration(seconds: 120);

class OrganDonationService {
  static Future<Map<String, dynamic>> submitLivingDonor(Map<String, dynamic> donorData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/organ/living-donor',
      data: donorData,
      options: Options(
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
        sendTimeout: _organDonationSendTimeout,
        receiveTimeout: _organDonationReceiveTimeout,
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Submits after-death pledge via multipart/form-data (required for id_photo and optional parent ID photos).
  static Future<Map<String, dynamic>> submitAfterDeathPledgeFormData(FormData formData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/organ/after-death-pledge',
      data: formData,
      options: Options(
        sendTimeout: _organDonationSendTimeout,
        receiveTimeout: _organDonationReceiveTimeout,
      ),
    );
    return response.data ?? {};
  }

  @Deprecated('Use submitAfterDeathPledgeFormData with FormData including id_photo file')
  static Future<Map<String, dynamic>> submitAfterDeathPledge(Map<String, dynamic> pledgeData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post('/organ/after-death-pledge', data: pledgeData);
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getLivingDonors() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/admin/dashboard/living-donors');
    return response.data;
  }

  static Future<Map<String, dynamic>> getLivingDonorDetail(String code) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/admin/dashboard/living-donors/$code');
    return response.data;
  }

  static Future<Map<String, dynamic>> getAfterDeathPledges() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/admin/dashboard/after-death-pledges');
    return response.data;
  }

  static Future<Map<String, dynamic>> getAfterDeathPledgeDetail(String code) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/admin/dashboard/after-death-pledges/$code');
    return response.data;
  }
}

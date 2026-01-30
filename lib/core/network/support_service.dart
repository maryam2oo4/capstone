import 'package:dio/dio.dart';
import 'api_client.dart';

class SupportService {
  static Future<Map<String, dynamic>> submitTicket(Map<String, dynamic> ticketData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/support/tickets',
      data: ticketData,
      options: Options(
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> getTickets() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/support/tickets');
    return response.data;
  }

  static Future<Map<String, dynamic>> getTicketDetail(int id) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/support/tickets/$id');
    return response.data;
  }
}

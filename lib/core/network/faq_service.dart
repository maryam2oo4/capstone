import 'api_client.dart';

class FaqService {
  /// Fetches FAQs from the backend. Optional [category] filter (use null or 'All' for all).
  static Future<Map<String, dynamic>> getFaqs({String? category}) async {
    final dio = await ApiClient.instance.dio();
    final path = category != null &&
            category.isNotEmpty &&
            category != 'All'
        ? '/faqs?category=${Uri.encodeComponent(category)}'
        : '/faqs';
    final response = await dio.get(path);
    return response.data as Map<String, dynamic>;
  }
}

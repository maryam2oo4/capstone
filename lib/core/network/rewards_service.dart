import 'package:dio/dio.dart';
import 'api_client.dart';

class RewardsService {
  static Future<Map<String, dynamic>> getRewards() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/donor/rewards');
    return response.data;
  }

  static Future<Map<String, dynamic>> getRewardsShop() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/donor/rewards/shop');
    return response.data;
  }

  static Future<Map<String, dynamic>> getRewardsShopPublic() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/rewards/shop-public');
    return response.data;
  }

  static Future<Map<String, dynamic>> purchaseReward(Map<String, dynamic> purchaseData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post('/donor/rewards/purchase', data: purchaseData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getBloodHeroes() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/blood-heroes');
    return response.data;
  }
}

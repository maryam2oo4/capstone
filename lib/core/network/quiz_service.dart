import 'package:dio/dio.dart';
import 'api_client.dart';

class QuizService {
  static final _jsonOptions = Options(
    contentType: 'application/json',
    headers: {'Accept': 'application/json'},
  );

  static Future<Map<String, dynamic>> getQuestions(int level) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/quiz/questions/$level');
    return response.data;
  }

  static Future<Map<String, dynamic>> getProgress() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/quiz/progress');
    return response.data;
  }

  static Future<Map<String, dynamic>> getQuizHistory() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/quiz/history');
    return response.data;
  }

  static Future<Map<String, dynamic>> answerQuestion(Map<String, dynamic> answerData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/quiz/answer-question',
      data: answerData,
      options: _jsonOptions,
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> completeLevel(Map<String, dynamic> levelData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/quiz/complete-level',
      data: levelData,
      options: _jsonOptions,
    );
    return response.data ?? {};
  }

  static Future<Map<String, dynamic>> getLeaderboard() async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.get('/quiz/leaderboard');
    return response.data;
  }

  static Future<Map<String, dynamic>> playMiniGame(Map<String, dynamic> gameData) async {
    final dio = await ApiClient.instance.dio();
    final response = await dio.post<Map<String, dynamic>>(
      '/mini-game/play',
      data: gameData,
      options: _jsonOptions,
    );
    return response.data ?? {};
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  Dio? _dio;

  String _normalizeBaseUrl(String url) {
    // Ensure the base URL points at Laravel's API routes (which are under /api).
    // Examples:
    // - https://example.com            -> https://example.com/api
    // - https://example.com/           -> https://example.com/api
    // - https://example.com/api        -> https://example.com/api
    // - https://example.com/api/       -> https://example.com/api
    final trimmed = url.trim().replaceAll(RegExp(r'\/+$'), '');
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

  String _defaultBaseUrl() {
    // IMPORTANT:
    // - Android emulator: 10.0.2.2 maps to your PC localhost
    // - Real phone: replace with your PC LAN IP by storing "api_base_url" in prefs (recommended)
    if (kIsWeb) return _normalizeBaseUrl('http://localhost:8000');
    if (Platform.isAndroid) return _normalizeBaseUrl('http://10.0.2.2:8000');
    return _normalizeBaseUrl('http://localhost:8000');
  }

  Future<Dio> dio() async {
    if (_dio != null) return _dio!;

    final prefs = await SharedPreferences.getInstance();
    final rawBaseUrl = prefs.getString('api_base_url');
    final baseUrl = rawBaseUrl != null ? _normalizeBaseUrl(rawBaseUrl) : _defaultBaseUrl();

    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Accept': 'application/json'},
        // Some backend operations (like creating appointments) can legitimately
        // take longer, especially on first cold starts. Give them more time
        // before treating as a hard failure.
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // Attach Bearer token automatically (if exists)
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
      ),
    );

    _dio = d;
    return d;
  }

  Future<void> setBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _normalizeBaseUrl(baseUrl));
    _dio = null; // rebuild on next access
  }
}


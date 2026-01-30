import 'package:dio/dio.dart';
import '../models/api_response.dart';

class ApiHelper {
  static Future<ApiResponse<T>> handleRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await request();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = fromJson(response.data);
        return ApiResponse.success(data, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout. Please check your internet.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Request timeout. Please try again.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Server timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = e.response?.data?['message'] ?? 
                       'Server error: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'An unexpected error occurred';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Invalid SSL certificate. Please check your connection.';
          break;
      }
      
      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<void>> handleVoidRequest(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout. Please check your internet.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Request timeout. Please try again.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Server timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = e.response?.data?['message'] ?? 
                       'Server error: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'An unexpected error occurred';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Invalid SSL certificate. Please check your connection.';
          break;
      }
      
      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }
}

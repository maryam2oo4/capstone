class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiError({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiError: $message (Status: $statusCode)';
  }
}

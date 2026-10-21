import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio singleton với JWT interceptor tự động gắn Authorization header
class ApiClient {
  ApiClient._();

  // Android emulator → localhost. Đổi thành URL deploy khi release.
  static const String baseUrl = 'http://10.0.2.2:8080';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tự động gắn Bearer token nếu có
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token hết hạn → xóa token (AuthViewModel sẽ điều hướng về Login)
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
          }
          return handler.next(error);
        },
      ),
    );
    return _dio;
  }
}

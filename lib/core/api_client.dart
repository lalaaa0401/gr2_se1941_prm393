import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import 'error_bus.dart';

/// Dio singleton với JWT interceptor tự động gắn Authorization header,
/// 401 auto-logout, và phát lỗi qua ErrorBus.
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
            // Token hết hạn → xóa token + thông báo AuthState để router redirect
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
            AuthState.instance.update(false);
          } else {
            // Phát lỗi ra ErrorBus để QuizLabApp hiển thị SnackBar
            ErrorBus.instance.emit(_buildMessage(error));
          }
          return handler.next(error);
        },
      ),
    );
    return _dio;
  }

  static String _buildMessage(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Lỗi kết nối. Vui lòng thử lại.';
    }
    return error.response?.data?['message']?.toString() ??
        'Đã có lỗi xảy ra.';
  }
}

import 'dart:async';

/// Singleton StreamController — phát error message để hiển thị SnackBar toàn cục.
///
/// API interceptor gọi emit() khi có lỗi mạng/server.
/// QuizZoneApp lắng nghe stream và hiển thị SnackBar.
class ErrorBus {
  static final ErrorBus instance = ErrorBus._();
  ErrorBus._();

  final _controller = StreamController<String>.broadcast();
  Stream<String> get errors => _controller.stream;

  void emit(String message) {
    if (!_controller.isClosed) _controller.add(message);
  }
}

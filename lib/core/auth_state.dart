import 'package:flutter/foundation.dart';

/// Singleton ChangeNotifier — giữ trạng thái đăng nhập cho GoRouter redirect.
///
/// Được cập nhật bởi AuthViewModel (login/logout/checkSession)
/// và ApiClient interceptor (khi nhận 401).
class AuthState extends ChangeNotifier {
  static final AuthState instance = AuthState._();
  AuthState._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void update(bool loggedIn) {
    if (_isLoggedIn == loggedIn) return;
    _isLoggedIn = loggedIn;
    notifyListeners();
  }
}

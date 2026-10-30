import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_strings.dart';
import '../core/auth_state.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  AuthViewModel(this._apiService);

  // ─── Public getters ────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // ─── Auth actions ──────────────────────────────────────────────────────────

  /// Login với real API. Lưu JWT vào SharedPreferences khi thành công.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      _currentUser = user;
      if (user.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', user.token!);
      }
      _isLoggedIn = true;
      _isLoading = false;
      AuthState.instance.update(true);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data?['message']?.toString() ?? AppStrings.errorNetwork;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register với real API.
  Future<bool> register(
      String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(email, password, fullName);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data?['message']?.toString() ?? AppStrings.errorNetwork;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear session và xóa token khỏi SharedPreferences.
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    AuthState.instance.update(false);
    notifyListeners();
  }

  /// Đọc token từ SharedPreferences; nếu tồn tại, gọi getMe() để restore user.
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      notifyListeners();
      return;
    }
    try {
      _currentUser = await _apiService.getMe();
      _isLoggedIn = true;
    } catch (_) {
      // Token hết hạn hoặc không hợp lệ
      await prefs.remove('access_token');
      _isLoggedIn = false;
    }
    AuthState.instance.update(_isLoggedIn);
    notifyListeners();
  }

  String _extractMessage(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return AppStrings.errorUnknown;
  }
}

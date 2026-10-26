import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  AuthViewModel(this._apiService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  /// Mock login: accept any email/password, create fake User, 800ms delay.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentUser = User(
        id: 1,
        email: email,
        fullName: 'User',
        token: 'mock_access_token',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _currentUser!.token!);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mock register: same pattern as login, 800ms delay.
  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentUser = User(
        id: 1,
        email: email,
        fullName: fullName,
        token: 'mock_access_token',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear current user and remove access_token from SharedPreferences.
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }

  /// Read 'access_token' from SharedPreferences; if present set _isLoggedIn = true.
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }
}

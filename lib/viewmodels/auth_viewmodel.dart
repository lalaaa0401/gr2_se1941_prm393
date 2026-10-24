import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  AuthViewModel(this._apiService);
}

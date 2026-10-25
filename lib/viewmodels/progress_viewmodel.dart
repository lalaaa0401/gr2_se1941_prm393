import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProgressViewModel extends ChangeNotifier {
  final ApiService _apiService;
  ProgressViewModel(this._apiService);
}

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProgressViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;
  ProgressViewModel(this._apiService);
}

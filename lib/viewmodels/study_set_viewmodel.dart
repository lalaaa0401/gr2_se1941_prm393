import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StudySetViewModel extends ChangeNotifier {
  final ApiService _apiService;
  StudySetViewModel(this._apiService);
}

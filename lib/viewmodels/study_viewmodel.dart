import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StudyViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;
  StudyViewModel(this._apiService);
}

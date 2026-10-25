import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final ApiService _apiService;
  NotificationViewModel(this._apiService);
}

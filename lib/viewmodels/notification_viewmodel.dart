import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class NotificationViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;
  NotificationViewModel(this._apiService);
}

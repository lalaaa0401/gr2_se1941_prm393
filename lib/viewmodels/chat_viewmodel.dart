import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ChatViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;
  ChatViewModel(this._apiService);
}

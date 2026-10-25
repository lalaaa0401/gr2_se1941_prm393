import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ApiService _apiService;
  ChatViewModel(this._apiService);
}

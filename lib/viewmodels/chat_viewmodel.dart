import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_strings.dart';
import '../models/message.dart';
import '../services/api_service.dart';

/// T4-P5-01 – ViewModel cho trang chat theo study set.
///
/// Hỗ trợ load tin nhắn, gửi tin nhắn với optimistic update.
class ChatViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  int? _currentSetId;
  String? _errorMessage;

  ChatViewModel(this._apiService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  int? get currentSetId => _currentSetId;
  String? get errorMessage => _errorMessage;

  /// Load tin nhắn theo study set. Reset state nếu set khác.
  Future<void> loadMessages(int setId) async {
    if (_isLoading) return;
    if (_currentSetId != setId) {
      _messages = [];
      _currentSetId = setId;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages(setId);
    } on DioException catch (e) {
      _errorMessage = e.type == DioExceptionType.connectionError
          ? AppStrings.errorNetwork
          : (e.response?.data?['message']?.toString() ??
              AppStrings.errorUnknown);
      _messages = [];
    } catch (_) {
      _errorMessage = AppStrings.errorUnknown;
      _messages = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Gửi tin nhắn. POST lên API, thêm vào danh sách khi thành công.
  Future<void> sendMessage(int setId, String content) async {
    if (content.trim().isEmpty || _isSending) return;
    _isSending = true;
    notifyListeners();

    try {
      final message =
          await _apiService.sendMessage(setId, content.trim());
      _messages = [..._messages, message];
    } catch (_) {
      // Silent fail — có thể thêm retry trong tương lai
    }

    _isSending = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _currentSetId = null;
    _errorMessage = null;
    notifyListeners();
  }
}

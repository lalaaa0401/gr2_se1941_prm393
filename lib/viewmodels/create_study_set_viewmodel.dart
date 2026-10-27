import 'package:flutter/foundation.dart';
import '../models/study_set.dart';
import '../services/api_service.dart';

/// ViewModel cho màn hình tạo bộ học mới.
/// Không import bất kỳ Flutter widget nào.
class CreateStudySetViewModel extends ChangeNotifier {
  final ApiService _apiService;

  CreateStudySetViewModel(this._apiService);

  // ─── State ────────────────────────────────────────────────────────────────

  String _title = '';
  String _description = '';
  String? _subject;
  bool _isPublic = true;

  /// Danh sách thẻ, mỗi thẻ là {'term': ..., 'definition': ...}
  final List<Map<String, String>> _cards = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _savedSuccessfully = false;

  // ─── Getters ─────────────────────────────────────────────────────────────

  String get title => _title;
  String get description => _description;
  String? get subject => _subject;
  bool get isPublic => _isPublic;
  List<Map<String, String>> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get savedSuccessfully => _savedSuccessfully;

  // ─── Setters ─────────────────────────────────────────────────────────────

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setSubject(String? value) {
    _subject = value;
    notifyListeners();
  }

  void setIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  // ─── Card management ─────────────────────────────────────────────────────

  /// Thêm thẻ mới vào danh sách
  void addCard(String term, String definition) {
    _cards.add({'term': term, 'definition': definition});
    notifyListeners();
  }

  /// Xóa thẻ tại vị trí [index]
  void removeCard(int index) {
    if (index >= 0 && index < _cards.length) {
      _cards.removeAt(index);
      notifyListeners();
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  /// Tạo bộ học và thêm toàn bộ flashcard lên API
  Future<void> saveStudySet() async {
    _isLoading = true;
    _errorMessage = null;
    _savedSuccessfully = false;
    notifyListeners();

    try {
      final StudySet newSet = await _apiService.createStudySet(
        _title,
        _description.isNotEmpty ? _description : null,
        _subject,
        _isPublic,
      );

      for (int i = 0; i < _cards.length; i++) {
        await _apiService.addFlashcard(
          newSet.id,
          _cards[i]['term']!,
          _cards[i]['definition']!,
          i,
        );
      }

      _savedSuccessfully = true;
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Đặt lại toàn bộ state về mặc định
  void reset() {
    _title = '';
    _description = '';
    _subject = null;
    _isPublic = true;
    _cards.clear();
    _isLoading = false;
    _errorMessage = null;
    _savedSuccessfully = false;
    notifyListeners();
  }
}

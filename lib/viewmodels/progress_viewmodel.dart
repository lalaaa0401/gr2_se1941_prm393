import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/quiz_result.dart';
import '../models/study_progress.dart';
import '../services/api_service.dart';

/// ViewModel cho trang tiến độ + profile
class ProgressViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ProgressSummary? _summary;
  List<StudySetProgress> _setProgress = [];
  List<QuizHistoryItem> _quizHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProgressViewModel(this._apiService);

  ProgressSummary? get summary => _summary;
  List<StudySetProgress> get setProgress => _setProgress;
  List<QuizHistoryItem> get quizHistory => _quizHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProgress() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getProgressSummary(),
        _apiService.getProgressSets(),
        _apiService.getMyQuizResults(),
      ]);
      _summary = results[0] as ProgressSummary;
      _setProgress = results[1] as List<StudySetProgress>;
      _quizHistory = results[2] as List<QuizHistoryItem>;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message']?.toString() ??
          'Lỗi kết nối. Vui lòng thử lại.';
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _summary = null;
    _setProgress = [];
    _quizHistory = [];
    await loadProgress();
  }
}

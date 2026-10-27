import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/study_progress.dart';
import '../services/api_service.dart';

/// T3-P5-01 – ViewModel cho trang tiến độ học tập.
class ProgressViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ProgressSummary? _summary;
  List<StudySetProgress> _setProgress = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProgressViewModel(this._apiService);

  ProgressSummary? get summary => _summary;
  List<StudySetProgress> get setProgress => _setProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProgress() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load summary (streak + weekly activity) và per-set progress song song
      final results = await Future.wait([
        _apiService.getProgressSummary(),
        _apiService.getProgressSets(),
      ]);
      _summary = results[0] as ProgressSummary;
      _setProgress = results[1] as List<StudySetProgress>;
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

  /// Refresh — reset state rồi load lại
  Future<void> refresh() async {
    _summary = null;
    _setProgress = [];
    await loadProgress();
  }
}

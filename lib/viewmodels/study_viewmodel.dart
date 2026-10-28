import 'package:flutter/foundation.dart';
import '../models/quiz_result.dart';
import '../models/study_progress.dart';
import '../services/api_service.dart';

/// T3-P4-01 – Quản lý phiên học flashcard và quiz.
///
/// - markKnown / markUnknown: cập nhật trạng thái cục bộ + gọi API ngầm (silent catch).
/// - submitQuizResult: lưu điểm quiz vào state và POST lên API ngầm.
/// - lastScore / lastTotal: dùng bởi QuizResultPage.
class StudyViewModel extends ChangeNotifier {
  final ApiService _apiService;

  final Set<int> _sessionKnownIds = {};

  int? _lastScore;
  int? _lastTotal;

  StudyViewModel(this._apiService);

  int? get lastScore => _lastScore;
  int? get lastTotal => _lastTotal;
  Set<int> get sessionKnownIds => Set.unmodifiable(_sessionKnownIds);

  /// Bắt đầu phiên học mới — reset session
  void startSession(int studySetId) {
    _sessionKnownIds.clear();
    notifyListeners();
  }

  /// Đánh dấu thẻ là "biết" — gọi API ngầm
  Future<void> markKnown(int studySetId, int flashcardId) async {
    _sessionKnownIds.add(flashcardId);
    notifyListeners();
    try {
      await _apiService.updateCardProgress(
          studySetId, flashcardId, CardStatus.known);
    } catch (_) {
      // API chưa sẵn sàng — session vẫn được track locally
    }
  }

  /// Đánh dấu thẻ là "chưa biết" — gọi API ngầm
  Future<void> markUnknown(int studySetId, int flashcardId) async {
    _sessionKnownIds.remove(flashcardId);
    notifyListeners();
    try {
      await _apiService.updateCardProgress(
          studySetId, flashcardId, CardStatus.unknown);
    } catch (_) {}
  }

  /// Kết thúc phiên học, giải phóng session state
  void finishSession() {
    _sessionKnownIds.clear();
    notifyListeners();
  }

  /// Lưu kết quả quiz và submit lên API ngầm
  Future<QuizResult?> submitQuizResult(
      int studySetId, int score, int total) async {
    _lastScore = score;
    _lastTotal = total;
    notifyListeners();
    try {
      return await _apiService.submitQuizResult(studySetId, score, total);
    } catch (_) {
      return null;
    }
  }
}

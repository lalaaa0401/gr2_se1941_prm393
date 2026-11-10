import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/flashcard.dart';
import '../models/quiz_result.dart';
import '../models/study_progress.dart';
import '../services/api_service.dart';

/// T3-P4-01 – Quản lý phiên học flashcard và quiz.
///
/// - markKnown / markUnknown: cập nhật trạng thái cục bộ + gọi API ngầm (silent catch).
/// - submitQuizResult: lưu điểm quiz vào state và POST lên API ngầm.
/// - lastScore / lastTotal: dùng bởi QuizResultPage.
/// - wrongCards: danh sách thẻ trả lời sai trong phiên quiz.
/// - weakCards: danh sách thẻ UNKNOWN/LEARNING từ API progress.
class StudyViewModel extends ChangeNotifier {
  final ApiService _apiService;

  final Set<int> _sessionKnownIds = {};

  int? _lastScore;
  int? _lastTotal;

  // ─── Wrong / Weak cards ──────────────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;
  List<Flashcard> _wrongCards = [];
  List<Flashcard> _quizCards = []; // override for quiz-wrong-only mode
  List<Flashcard> _weakCards = [];

  // ─── Quiz History ─────────────────────────────────────────────────────────
  List<QuizResult> _quizHistory = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  StudyViewModel(this._apiService);

  int? get lastScore => _lastScore;
  int? get lastTotal => _lastTotal;
  Set<int> get sessionKnownIds => Set.unmodifiable(_sessionKnownIds);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<QuizResult> get quizHistory => List.unmodifiable(_quizHistory);
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;

  /// Danh sách thẻ trả lời sai trong phiên quiz hiện tại (immutable view).
  List<Flashcard> get wrongCards => List.unmodifiable(_wrongCards);

  /// Cards được set trước khi vào quiz — chỉ quiz những thẻ này
  List<Flashcard> get quizCards => List.unmodifiable(_quizCards);

  void setQuizCards(List<Flashcard> cards) {
    _quizCards = List<Flashcard>.from(cards);
    notifyListeners();
  }

  void clearQuizCards() {
    _quizCards = [];
  }

  /// Danh sách thẻ yếu (UNKNOWN/LEARNING) từ API (immutable view).
  List<Flashcard> get weakCards => List.unmodifiable(_weakCards);

  // ─── Session ─────────────────────────────────────────────────────────────

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
      final wrongIds = _wrongCards.map((c) => c.id).toList();
      return await _apiService.submitQuizResult(studySetId, score, total,
          wrongCardIds: wrongIds);
    } catch (_) {
      return null;
    }
  }

  // ─── Wrong cards ─────────────────────────────────────────────────────────

  /// Xóa danh sách thẻ sai — gọi khi bắt đầu phiên quiz mới.
  void clearWrongCards() {
    _wrongCards = [];
    notifyListeners();
  }

  /// Thêm thẻ vào danh sách thẻ sai (gọi từ QuizPage khi trả lời sai).
  /// Không thêm nếu thẻ đã có trong danh sách.
  void addWrongCard(Flashcard card) {
    if (!_wrongCards.any((c) => c.id == card.id)) {
      _wrongCards = [..._wrongCards, card];
      notifyListeners();
    }
  }

  // ─── Weak cards ──────────────────────────────────────────────────────────

  /// Tải danh sách thẻ yếu (UNKNOWN/LEARNING) từ API progress của [studySetId].
  Future<void> loadWeakCards(int studySetId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final entries = await _apiService.getSetProgress(studySetId);
      _weakCards = entries
          .where((e) {
            final status = (e['status'] as String?)?.toUpperCase() ?? '';
            return status == 'UNKNOWN' || status == 'LEARNING';
          })
          .map((e) => Flashcard.fromJson(e['flashcard'] as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _weakCards = [];
      _errorMessage = e.response?.data['message'] ?? 'Lỗi kết nối';
    } catch (_) {
      _weakCards = [];
      _errorMessage = 'Không thể tải thẻ yếu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Quiz History ─────────────────────────────────────────────────────────

  /// Tải lịch sử quiz của một bộ học từ API.
  Future<void> loadQuizHistory(int studySetId) async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();
    try {
      _quizHistory = await _apiService.getQuizResultsBySet(studySetId);
    } on DioException catch (e) {
      _quizHistory = [];
      _historyError = e.response?.data['message'] ?? 'Lỗi kết nối';
    } catch (_) {
      _quizHistory = [];
      _historyError = 'Không thể tải lịch sử quiz';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Tải chi tiết thẻ sai của một lần làm quiz.
  Future<QuizResultDetail?> loadQuizDetails(int quizId) async {
    try {
      return await _apiService.getQuizResultDetails(quizId);
    } catch (_) {
      return null;
    }
  }

  /// Gán danh sách thẻ cần ôn lại (dùng trước khi vào ReviewFlashcardPage.wrong).
  void setReviewCards(List<Flashcard> cards) {
    _wrongCards = List<Flashcard>.from(cards);
    notifyListeners();
  }
}

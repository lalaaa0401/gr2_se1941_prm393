import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/flashcard.dart';
import '../models/study_set.dart';
import '../services/api_service.dart';

/// ViewModel quản lý bộ học của user hiện tại
/// P1 — anhlphe180185
class MyStudySetsViewModel extends ChangeNotifier {
  final ApiService _api;

  List<StudySet> _sets = [];
  bool _isLoading = false;
  String? _errorMessage;

  MyStudySetsViewModel(this._api);

  List<StudySet> get sets => List.unmodifiable(_sets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải danh sách bộ học của user
  Future<void> loadMySets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _sets = await _api.getMyStudySets();
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data?['message']?.toString() ?? 'Lỗi kết nối mạng';
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa bộ học
  Future<bool> deleteSet(int id) async {
    try {
      await _api.deleteStudySet(id);
      _sets.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật thông tin bộ học
  Future<bool> updateSet(int id, String title,
      {String? description, String? subject, bool isPublic = true}) async {
    try {
      final updated = await _api.updateStudySet(id, title,
          description: description, subject: subject, isPublic: isPublic);
      final idx = _sets.indexWhere((s) => s.id == id);
      if (idx != -1) {
        // Giữ lại flashcards hiện có sau khi update
        _sets[idx] = StudySet(
          id: updated.id,
          title: updated.title,
          description: updated.description,
          subject: updated.subject,
          isPublic: updated.isPublic,
          cardCount: _sets[idx].cardCount,
          createdAt: updated.createdAt,
          owner: updated.owner,
          flashcards: _sets[idx].flashcards,
          knownCards: _sets[idx].knownCards,
          completionRate: _sets[idx].completionRate,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Thêm flashcard mới vào bộ học, rồi reload set đó để lấy danh sách mới nhất
  Future<bool> addFlashcard(int setId, String term, String definition) async {
    try {
      final idx = _sets.indexWhere((s) => s.id == setId);
      final position = idx != -1 ? _sets[idx].flashcards.length : 0;
      await _api.addFlashcard(setId, term, definition, position);
      // Reload set detail để lấy flashcards mới nhất
      final refreshed = await _api.getStudySetDetail(setId);
      if (idx != -1) {
        _sets[idx] = refreshed;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Chỉnh sửa flashcard
  Future<bool> updateFlashcard(
      int cardId, String term, String definition, int position) async {
    try {
      await _api.updateFlashcard(cardId, term, definition, position);
      // Cập nhật local state
      for (var i = 0; i < _sets.length; i++) {
        final cards = _sets[i].flashcards;
        final cardIdx = cards.indexWhere((c) => c.id == cardId);
        if (cardIdx != -1) {
          final updatedCards = List.of(cards);
          updatedCards[cardIdx] = Flashcard(
            id: cardId,
            term: term,
            definition: definition,
            imageUrl: cards[cardIdx].imageUrl,
            position: position,
          );
          _sets[i] = StudySet(
            id: _sets[i].id,
            title: _sets[i].title,
            description: _sets[i].description,
            subject: _sets[i].subject,
            isPublic: _sets[i].isPublic,
            cardCount: _sets[i].cardCount,
            createdAt: _sets[i].createdAt,
            owner: _sets[i].owner,
            flashcards: updatedCards,
            knownCards: _sets[i].knownCards,
            completionRate: _sets[i].completionRate,
          );
          break;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Xóa flashcard, cập nhật local state bằng cách xóa card khỏi set tương ứng
  Future<bool> deleteFlashcard(int cardId, int setId) async {
    try {
      await _api.deleteFlashcard(cardId);
      final idx = _sets.indexWhere((s) => s.id == setId);
      if (idx != -1) {
        final updatedCards =
            _sets[idx].flashcards.where((c) => c.id != cardId).toList();
        _sets[idx] = StudySet(
          id: _sets[idx].id,
          title: _sets[idx].title,
          description: _sets[idx].description,
          subject: _sets[idx].subject,
          isPublic: _sets[idx].isPublic,
          cardCount: updatedCards.length,
          createdAt: _sets[idx].createdAt,
          owner: _sets[idx].owner,
          flashcards: updatedCards,
          knownCards: _sets[idx].knownCards,
          completionRate: _sets[idx].completionRate,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

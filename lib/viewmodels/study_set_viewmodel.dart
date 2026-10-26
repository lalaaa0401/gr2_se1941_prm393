import 'package:flutter/foundation.dart';
import '../models/study_set.dart';
import '../models/flashcard.dart';
import '../services/api_service.dart';

class StudySetViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;

  List<StudySet> _studySets = [];
  List<StudySet> _filtered = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedSubject;

  StudySetViewModel(this._apiService);

  List<StudySet> get studySets => _filtered;
  bool get isLoading => _isLoading;
  String? get selectedSubject => _selectedSubject;

  List<String> get subjects {
    final seen = <String>{};
    return _studySets
        .where((s) => s.subject != null)
        .map((s) => s.subject!)
        .where(seen.add)
        .toList();
  }

  StudySet? getStudySetById(int id) {
    try {
      return _studySets.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadStudySets() async {
    if (_isLoading || _studySets.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _studySets = [
      StudySet(
        id: 1,
        title: 'English Vocabulary B2',
        subject: 'English',
        cardCount: 28,
        isPublic: true,
        flashcards: [
          Flashcard(
            id: 1,
            term: 'Ambiguous',
            definition: 'Có thể hiểu theo nhiều nghĩa',
            position: 0,
          ),
          Flashcard(
            id: 2,
            term: 'Benevolent',
            definition: 'Nhân từ, tốt bụng',
            position: 1,
          ),
          Flashcard(
            id: 3,
            term: 'Concise',
            definition: 'Súc tích, ngắn gọn',
            position: 2,
          ),
        ],
      ),
      StudySet(
        id: 2,
        title: 'Kiến trúc phần mềm',
        subject: 'SE',
        cardCount: 15,
        isPublic: true,
        flashcards: [
          Flashcard(
            id: 4,
            term: 'SOLID',
            definition: '5 nguyên tắc thiết kế OOP',
            position: 0,
          ),
          Flashcard(
            id: 5,
            term: 'Dependency Injection',
            definition: 'Tiêm phụ thuộc từ bên ngoài',
            position: 1,
          ),
        ],
      ),
      StudySet(
        id: 3,
        title: 'Flutter Widgets',
        subject: 'Mobile',
        cardCount: 20,
        isPublic: true,
        flashcards: [
          Flashcard(
            id: 6,
            term: 'StatelessWidget',
            definition: 'Widget không có state nội tại',
            position: 0,
          ),
          Flashcard(
            id: 7,
            term: 'StatefulWidget',
            definition: 'Widget có state có thể thay đổi',
            position: 1,
          ),
        ],
      ),
      StudySet(
        id: 4,
        title: 'Toán rời rạc',
        subject: 'Math',
        cardCount: 35,
        isPublic: false,
        flashcards: [
          Flashcard(
            id: 8,
            term: 'Đồ thị vô hướng',
            definition: 'Graph không có chiều cạnh',
            position: 0,
          ),
        ],
      ),
    ];

    _filtered = List.from(_studySets);
    _isLoading = false;
    notifyListeners();
  }

  void searchStudySets(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterBySubject(String? subject) {
    _selectedSubject = subject;
    _applyFilters();
  }

  void _applyFilters() {
    _filtered = _studySets.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSubject =
          _selectedSubject == null || s.subject == _selectedSubject;
      return matchesSearch && matchesSubject;
    }).toList();
    notifyListeners();
  }
}

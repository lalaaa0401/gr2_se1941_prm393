import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_strings.dart';
import '../models/study_set.dart';
import '../services/api_service.dart';

class StudySetViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<StudySet> _studySets = [];
  List<StudySet> _filtered = [];
  StudySet? _continueSet; // Set nên học tiếp
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedSubject;

  StudySetViewModel(this._apiService);

  List<StudySet> get studySets => _filtered;
  StudySet? get continueSet => _continueSet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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

  Future<void> loadStudySets({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh && _studySets.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load study sets và "continue" set song song
      final results = await Future.wait([
        _apiService.getStudySets(),
        _apiService.getStudySetToContinue(),
      ]);
      _studySets = results[0] as List<StudySet>;
      final beContinue = results[1] as StudySet?;
      // Fallback: nếu BE chưa có /continue, tự tìm set đang học dở
      _continueSet = beContinue ?? _deriveContinueSet();
      _applyFilters();
    } on DioException catch (e) {
      _errorMessage = e.type == DioExceptionType.connectionError
          ? AppStrings.errorNetwork
          : (e.response?.data?['message']?.toString() ??
              AppStrings.errorUnknown);
    } catch (e) {
      _errorMessage = AppStrings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Tìm set đang học dở có completionRate cao nhất (fallback khi BE chưa có /continue)
  StudySet? _deriveContinueSet() {
    final inProgress = _studySets
        .where((s) => s.completionRate > 0.0 && s.completionRate < 1.0)
        .toList();
    if (inProgress.isEmpty) return null;
    return inProgress.reduce(
        (a, b) => a.completionRate > b.completionRate ? a : b);
  }
}



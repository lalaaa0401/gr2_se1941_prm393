import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_strings.dart';
import '../models/study_set.dart';
import '../services/api_service.dart';

class StudySetViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<StudySet> _studySets = [];
  List<StudySet> _filtered = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedSubject;

  StudySetViewModel(this._apiService);

  List<StudySet> get studySets => _filtered;
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

  /// Tải danh sách study set từ API. Bỏ qua nếu đang loading hoặc đã có dữ liệu.
  Future<void> loadStudySets({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh && _studySets.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _studySets = await _apiService.getStudySets();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = e.type == DioExceptionType.connectionError
          ? AppStrings.errorNetwork
          : (e.response?.data?['message']?.toString() ??
              AppStrings.errorUnknown);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = AppStrings.errorUnknown;
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
}



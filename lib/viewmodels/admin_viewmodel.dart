import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/admin.dart';
import '../models/study_set.dart';
import '../services/api_service.dart';

/// ViewModel cho màn hình quản trị admin
class AdminViewModel extends ChangeNotifier {
  final ApiService _api;

  AdminStats? _stats;
  List<AdminUser> _users = [];
  List<StudySet> _studySets = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminViewModel(this._api);

  AdminStats? get stats => _stats;
  List<AdminUser> get users => _users;
  List<StudySet> get studySets => _studySets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải toàn bộ dữ liệu admin song song
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAdminStats(),
        _api.getAdminUsers(),
        _api.getAdminStudySets(),
      ]);
      _stats = results[0] as AdminStats;
      _users = results[1] as List<AdminUser>;
      _studySets = results[2] as List<StudySet>;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message']?.toString() ??
          'Lỗi kết nối. Vui lòng thử lại.';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Khoá / mở khoá người dùng và cập nhật local state
  Future<void> toggleBlock(int userId) async {
    try {
      await _api.toggleBlockUser(userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final updated = List<AdminUser>.from(_users);
        updated[idx] = updated[idx].copyWith(isBlocked: !updated[idx].isBlocked);
        _users = updated;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message']?.toString() ??
          'Lỗi kết nối. Vui lòng thử lại.';
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Xoá bộ học và cập nhật local state
  Future<void> deleteStudySet(int setId) async {
    try {
      await _api.adminDeleteStudySet(setId);
      _studySets = _studySets.where((s) => s.id != setId).toList();
      if (_stats != null) {
        _stats = AdminStats(
          totalUsers: _stats!.totalUsers,
          totalSets: (_stats!.totalSets - 1).clamp(0, 999999),
          totalQuizzes: _stats!.totalQuizzes,
          activeToday: _stats!.activeToday,
        );
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message']?.toString() ??
          'Lỗi kết nối. Vui lòng thử lại.';
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

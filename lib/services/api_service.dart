import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/admin.dart';
import '../models/user.dart';
import '../models/study_set.dart';
import '../models/quiz_result.dart';
import '../models/notification.dart';
import '../models/message.dart';
import '../models/study_progress.dart';

/// Tất cả HTTP calls đến QuizLab REST API
/// Base URL: http://10.0.2.2:8080
/// Response format: { "success": bool, "message": String, "data": T }
class ApiService {
  Dio get _dio => ApiClient.instance;

  // ─── AUTH ────────────────────────────────────────────────────────────────

  /// POST /auth/login → User (with token)
  Future<User> login(String email, String password) async {
    final response = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// POST /auth/register (phone + school optional) — trả về User với token
  Future<User> register(String email, String password, String fullName,
      {String? phone, String? school}) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (school != null && school.isNotEmpty) 'school': school,
    });
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// GET /auth/me → User
  Future<User> getMe() async {
    final response = await _dio.get('/auth/me');
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// PUT /auth/me — cập nhật profile (fullName + phone + school + bio)
  Future<User> updateMe(String fullName,
      {String? avatarUrl, String? phone, String? school, String? bio}) async {
    final response = await _dio.put('/auth/me', data: {
      'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (phone != null) 'phone': phone,
      if (school != null) 'school': school,
      if (bio != null) 'bio': bio,
    });
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  // ─── STUDY SETS ──────────────────────────────────────────────────────────

  /// GET /api/study-sets?search=&page=&size=20
  Future<List<StudySet>> getStudySets({String? search, int page = 0}) async {
    final response = await _dio.get('/api/study-sets',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'size': 20,
        });
    if (response.data['success'] == true) {
      final pageData = response.data['data'];
      return (pageData['content'] as List)
          .map((e) => StudySet.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/study-sets/mine
  Future<List<StudySet>> getMyStudySets() async {
    final response = await _dio.get('/api/study-sets/mine');
    if (response.data['success'] == true) {
      final pageData = response.data['data'];
      return (pageData['content'] as List)
          .map((e) => StudySet.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/study-sets/{id} → StudySet (with flashcards)
  Future<StudySet> getStudySetDetail(int id) async {
    final response = await _dio.get('/api/study-sets/$id');
    if (response.data['success'] == true) {
      return StudySet.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// POST /api/study-sets — tạo bộ học mới
  Future<StudySet> createStudySet(
    String title,
    String? description,
    String? subject,
    bool isPublic,
  ) async {
    final response = await _dio.post('/api/study-sets', data: {
      'title': title,
      if (description != null) 'description': description,
      if (subject != null) 'subject': subject,
      'isPublic': isPublic,
    });
    if (response.data['success'] == true) {
      return StudySet.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// POST /api/study-sets/{id}/flashcards — thêm flashcard vào bộ học
  Future<void> addFlashcard(
    int studySetId,
    String term,
    String definition,
    int position,
  ) async {
    final response = await _dio.post(
      '/api/study-sets/$studySetId/flashcards',
      data: {'term': term, 'definition': definition, 'position': position},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message']);
    }
  }

  // ─── PROGRESS ────────────────────────────────────────────────────────────

  /// PUT /api/progress/{setId} — cập nhật trạng thái một flashcard
  Future<void> updateCardProgress(int setId, int flashcardId, CardStatus status) async {
    final response = await _dio.put('/api/progress/$setId',
        data: {
          'flashcardId': flashcardId,
          'status': cardStatusToString(status),
        });
    if (response.data['success'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// GET /api/progress/summary → ProgressSummary (bao gồm streak + weeklyActivity)
  Future<ProgressSummary> getProgressSummary() async {
    final response = await _dio.get('/api/progress/summary');
    if (response.data['success'] == true) {
      return ProgressSummary.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/study-sets/continue → StudySet user nên học tiếp
  /// Trả về null nếu chưa học set nào
  Future<StudySet?> getStudySetToContinue() async {
    try {
      final response = await _dio.get('/api/study-sets/continue');
      if (response.data['success'] == true && response.data['data'] != null) {
        return StudySet.fromJson(response.data['data']);
      }
      return null;
    } catch (_) {
      return null; // Không crash nếu endpoint chưa có data
    }
  }
  Future<List<StudySetProgress>> getProgressSets() async {
    final response = await _dio.get('/api/progress/sets');
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => StudySetProgress.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/progress/{setId} → danh sách tiến độ từng thẻ trong bộ học
  /// Mỗi phần tử: { "flashcard": {...}, "status": "UNKNOWN"|"LEARNING"|"KNOWN" }
  Future<List<Map<String, dynamic>>> getSetProgress(int setId) async {
    final response = await _dio.get('/api/progress/$setId');
    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(
        (response.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/quiz-results/mine → lịch sử quiz của user
  Future<List<QuizHistoryItem>> getMyQuizResults() async {
    final response = await _dio.get('/api/quiz-results/mine');
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => QuizHistoryItem.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }
  Future<QuizResult> submitQuizResult(int studySetId, int score, int totalQuestions) async {
    final response = await _dio.post('/api/quiz-results',
        data: {
          'studySetId': studySetId,
          'score': score,
          'totalQuestions': totalQuestions,
        });
    if (response.data['success'] == true) {
      return QuizResult.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  // ─── NOTIFICATIONS ───────────────────────────────────────────────────────

  /// GET /api/notifications → `List<AppNotification>`
  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get('/api/notifications');
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/notifications/unread-count → int
  Future<int> getUnreadNotificationCount() async {
    final response = await _dio.get('/api/notifications/unread-count');
    if (response.data['success'] == true) {
      return response.data['data'] as int;
    }
    return 0;
  }

  /// PUT /api/notifications/{id}/read
  Future<void> markNotificationRead(int id) async {
    await _dio.put('/api/notifications/$id/read');
  }

  /// PUT /api/notifications/read-all
  Future<void> markAllNotificationsRead() async {
    await _dio.put('/api/notifications/read-all');
  }

  // ─── CHAT ────────────────────────────────────────────────────────────────

  /// GET /api/messages/{setId} → `List<Message>`
  Future<List<Message>> getMessages(int setId) async {
    final response = await _dio.get('/api/messages/$setId');
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => Message.fromJson(e))
          .toList();
    }
    throw Exception(response.data['message']);
  }

  /// POST /api/messages/{setId}
  Future<Message> sendMessage(int setId, String content) async {
    final response = await _dio.post('/api/messages/$setId',
        data: {'content': content});
    if (response.data['success'] == true) {
      return Message.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  // ─── ADMIN ───────────────────────────────────────────────────────────────

  /// GET /api/admin/stats → AdminStats
  Future<AdminStats> getAdminStats() async {
    final response = await _dio.get('/api/admin/stats');
    if (response.data['success'] == true) {
      return AdminStats.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/admin/users?page=&size=20 → `List<AdminUser>`
  /// data có thể là Map với 'content' key hoặc plain List
  Future<List<AdminUser>> getAdminUsers({int page = 0}) async {
    final response = await _dio.get('/api/admin/users',
        queryParameters: {'page': page, 'size': 20});
    if (response.data['success'] == true) {
      final raw = response.data['data'];
      final list = raw is Map ? raw['content'] as List : raw as List;
      return list.map((e) => AdminUser.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  /// PUT /api/admin/users/{userId}/toggle-block → message String
  Future<String> toggleBlockUser(int userId) async {
    final response =
        await _dio.put('/api/admin/users/$userId/toggle-block');
    if (response.data['success'] == true) {
      return response.data['message'] as String;
    }
    throw Exception(response.data['message']);
  }

  /// GET /api/admin/study-sets?page=&size=20 → `List<StudySet>`
  Future<List<StudySet>> getAdminStudySets({int page = 0}) async {
    final response = await _dio.get('/api/admin/study-sets',
        queryParameters: {'page': page, 'size': 20});
    if (response.data['success'] == true) {
      final raw = response.data['data'];
      final list = raw is Map ? raw['content'] as List : raw as List;
      return list.map((e) => StudySet.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  /// DELETE /api/admin/study-sets/{id}
  Future<void> adminDeleteStudySet(int id) async {
    final response = await _dio.delete('/api/admin/study-sets/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['message']);
    }
  }
}

import 'package:dio/dio.dart';
import '../core/api_client.dart';
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

  /// POST /auth/register
  Future<void> register(String email, String password, String fullName) async {
    final response = await _dio.post('/auth/register',
        data: {'email': email, 'password': password, 'fullName': fullName});
    if (response.data['success'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// GET /auth/me → User
  Future<User> getMe() async {
    final response = await _dio.get('/auth/me');
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  /// PUT /auth/me — cập nhật profile
  Future<User> updateMe(String fullName, {String? avatarUrl}) async {
    final response = await _dio.put('/auth/me',
        data: {'fullName': fullName, if (avatarUrl != null) 'avatarUrl': avatarUrl});
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

  // ─── QUIZ ────────────────────────────────────────────────────────────────

  /// POST /api/quiz-results — lưu kết quả quiz
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
}

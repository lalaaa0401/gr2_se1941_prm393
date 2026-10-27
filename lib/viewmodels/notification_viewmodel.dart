import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationViewModel(this._apiService);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _notifications = [
      AppNotification(
        id: 1,
        title: 'Chào mừng đến QuizZone!',
        body: 'Bắt đầu tạo bộ học đầu tiên của bạn',
        type: 'INFO',
        isRead: false,
        createdAt: '2026-10-26T09:00:00',
      ),
      AppNotification(
        id: 2,
        title: 'Quiz hoàn thành',
        body: 'Bạn đạt 8/10 câu đúng trong bộ English Vocabulary',
        type: 'ACHIEVEMENT',
        isRead: false,
        createdAt: '2026-10-25T14:30:00',
      ),
      AppNotification(
        id: 3,
        title: 'Nhắc nhở học tập',
        body: 'Hôm nay bạn chưa học thẻ nào',
        type: 'REMINDER',
        isRead: true,
        createdAt: '2026-10-24T08:00:00',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final n = _notifications[index];
      _notifications[index] = AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications
        .map(
          (n) => AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          ),
        )
        .toList();
    notifyListeners();
  }
}

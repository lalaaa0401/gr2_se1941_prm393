import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

/// T4-P5-02 – NotificationViewModel dùng real API.
///
/// - loadNotifications(): GET /api/notifications
/// - markAsRead(id): optimistic update + PUT /api/notifications/{id}/read (silent)
/// - markAllAsRead(): optimistic update + PUT /api/notifications/read-all (silent)
class NotificationViewModel extends ChangeNotifier {
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

    try {
      _notifications = await _apiService.getNotifications();
    } catch (_) {
      _notifications = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Optimistic markAsRead — cập nhật UI ngay, gọi API ngầm.
  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

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

    try {
      await _apiService.markNotificationRead(id);
    } catch (_) {}
  }

  /// Optimistic markAllAsRead — cập nhật UI ngay, gọi API ngầm.
  Future<void> markAllAsRead() async {
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

    try {
      await _apiService.markAllNotificationsRead();
    } catch (_) {}
  }
}

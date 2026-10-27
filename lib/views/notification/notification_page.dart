import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/app_text_styles.dart';
import '../../models/notification.dart';
import '../../viewmodels/notification_viewmodel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static final DateFormat _dateFormat = DateFormat('dd/MM', 'vi_VN');

  String _formatDate(String? createdAt) {
    if (createdAt == null) return '';
    try {
      return _dateFormat.format(DateTime.parse(createdAt));
    } catch (_) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo', style: AppTextStyles.h1),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: vm.markAllAsRead,
              tooltip: 'Đánh dấu tất cả đã đọc',
            ),
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.notifications.isEmpty) {
            return const Center(
              child: Text(AppStrings.emptyNotifications),
            );
          }
          return ListView.builder(
            itemCount: vm.notifications.length,
            itemBuilder: (context, index) {
              final n = vm.notifications[index];
              return _NotificationTile(
                notification: n,
                formattedDate: _formatDate(n.createdAt),
                onTap: () => vm.markAsRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final String formattedDate;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor:
          notification.isRead ? AppColors.surface : AppColors.primaryLight,
      leading: const Icon(
        Icons.notifications_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text(
        notification.title,
        style: notification.isRead
            ? null
            : const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        notification.body,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: Text(
        formattedDate,
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }
}

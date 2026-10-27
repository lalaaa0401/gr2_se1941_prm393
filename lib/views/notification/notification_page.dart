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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [A] Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text('Thông báo', style: AppTextStyles.h1),
                  const Spacer(),
                  Consumer<NotificationViewModel>(
                    builder: (context, vm, _) => TextButton(
                      onPressed: vm.markAllAsRead,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Đánh dấu đọc',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // [B] White sheet
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<NotificationViewModel>(
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
              ),
            ),
          ],
        ),
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
    final isRead = notification.isRead;
    return ListTile(
      tileColor: isRead ? AppColors.surface : AppColors.primaryLight,
      leading: Icon(
        isRead
            ? Icons.notifications_outlined
            : Icons.notifications_rounded,
        color: isRead ? AppColors.textSecondary : AppColors.primary,
      ),
      title: Text(
        notification.title,
        style: isRead
            ? AppTextStyles.body
            : AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
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

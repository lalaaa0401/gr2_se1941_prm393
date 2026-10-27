import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../viewmodels/notification_viewmodel.dart';

/// Widget chuông thông báo dùng lại ở nhiều màn.
/// Hiển thị badge đỏ khi có thông báo chưa đọc.
/// Nhấn vào mở bottom sheet danh sách thông báo.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  void _showNotificationSheet(BuildContext context) {
    // Tải thông báo (fire-and-forget)
    context.read<NotificationViewModel>().loadNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ChangeNotifierProvider.value(
        value: context.read<NotificationViewModel>(),
        child: const _NotificationSheetBody(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, vm, _) {
        return GestureDetector(
          onTap: () => _showNotificationSheet(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                if (vm.unreadCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${vm.unreadCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bottom sheet nội dung thông báo — không dùng Scaffold.
class _NotificationSheetBody extends StatelessWidget {
  const _NotificationSheetBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row: tiêu đề + nút đánh dấu đọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('Thông báo', style: AppTextStyles.h2),
                const Spacer(),
                Consumer<NotificationViewModel>(
                  builder: (context, vm, _) => TextButton(
                    onPressed: vm.markAllAsRead,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Đánh dấu đọc'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Danh sách thông báo
          Expanded(
            child: Consumer<NotificationViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.notifications.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có thông báo',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: vm.notifications.length,
                  itemBuilder: (context, i) {
                    final n = vm.notifications[i];
                    return ListTile(
                      tileColor: n.isRead
                          ? AppColors.surface
                          : AppColors.primaryLight,
                      leading: Icon(
                        n.isRead
                            ? Icons.notifications_outlined
                            : Icons.notifications_rounded,
                        color: n.isRead
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                      title: Text(
                        n.title,
                        style: n.isRead
                            ? AppTextStyles.body
                            : AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                      subtitle: Text(
                        n.body,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => vm.markAsRead(n.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'study_set/study_set_list_page.dart';
import 'progress/progress_page.dart';
import 'notification/notification_page.dart';
import 'profile/profile_page.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';

/// Màn hình chính với BottomNavigationBar 5 tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách 5 page tương ứng với từng tab
  static const List<Widget> _pages = [
    StudySetListPage(),
    ProgressPage(),
    // ChatPage cần studySetId, dùng placeholder ở tab chat
    _ChatTabPlaceholder(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Consumer<NotificationViewModel>(
        builder: (context, notifVm, _) => NavigationBar(
          elevation: 0,
          backgroundColor: AppColors.surface,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primaryLight,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: AppStrings.navStudySets,
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: AppStrings.navProgress,
            ),
            const NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: AppStrings.navChat,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: notifVm.unreadCount > 0,
                label: Text('${notifVm.unreadCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: notifVm.unreadCount > 0,
                label: Text('${notifVm.unreadCount}'),
                child: const Icon(Icons.notifications),
              ),
              label: AppStrings.navNotifications,
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder cho Chat tab (ChatPage cần studySetId nên không dùng trực tiếp ở tab)
class _ChatTabPlaceholder extends StatelessWidget {
  const _ChatTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chọn bộ học để xem bình luận')),
    );
  }
}

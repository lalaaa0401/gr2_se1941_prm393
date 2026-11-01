import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'study_set/study_set_list_page.dart';
import 'progress/progress_page.dart';
import 'my_sets/my_study_sets_page.dart';
import 'profile/profile_page.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/home_tab_controller.dart';

/// Màn hình chính với BottomNavigationBar 4 tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách 4 page tương ứng với từng tab
  static const List<Widget> _pages = [
    StudySetListPage(),    // index 0 — Học
    ProgressPage(),        // index 1 — Tiến độ
    MyStudySetsPage(),     // index 2 — Bộ học
    ProfilePage(),         // index 3 — Hồ sơ
  ];

  HomeTabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tabController = context.read<HomeTabController>();
      _tabController!.addListener(_onTabChange);
    });
  }

  void _onTabChange() {
    if (!mounted) return;
    setState(() {
      _selectedIndex = _tabController!.activeIndex;
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          // Đồng bộ controller để các widget khác (e.g. AvatarSheet)
          // biết tab hiện tại.
          context.read<HomeTabController>().switchTo(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: AppStrings.navStudySets,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: AppStrings.navProgress,
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Bộ học',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}

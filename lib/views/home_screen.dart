import 'package:flutter/material.dart';
import 'study_set/study_set_list_page.dart';
import 'progress/progress_page.dart';
import 'create/create_study_set_page.dart';
import 'profile/profile_page.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';

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
    StudySetListPage(),
    ProgressPage(),
    CreateStudySetPage(),
    ProfilePage(),
  ];

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
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: AppStrings.navCreate,
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

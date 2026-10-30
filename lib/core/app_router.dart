import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_state.dart';
import '../views/home_screen.dart';
import '../views/splash_screen.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/study_set/study_set_detail_page.dart';
import '../views/study/flashcard_study_page.dart';
import '../views/study/quiz_page.dart';
import '../views/study/quiz_result_page.dart';
import '../views/profile/profile_page.dart';
import '../views/chat/chat_page.dart';

/// Tất cả route names
class AppRoutes {
  static const splash         = '/';
  static const login          = '/login';
  static const register       = '/register';
  static const home           = '/home';
  static const studySetDetail = '/study-set/:id';
  static const flashcardStudy = '/study/:id/flashcard';
  static const quiz           = '/study/:id/quiz';
  static const quizResult     = '/study/:id/quiz/result';
  static const studyChat      = '/study/:id/chat';
  static const profile        = '/profile';
}

/// go_router singleton với redirect tự động dựa trên AuthState.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: AuthState.instance,
  redirect: (context, state) {
    final isLoggedIn = AuthState.instance.isLoggedIn;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == AppRoutes.login ||
        loc == AppRoutes.register ||
        loc == AppRoutes.splash;

    // Chưa đăng nhập và đang truy cập route cần auth → về Login
    if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.studySetDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return StudySetDetailPage(studySetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.flashcardStudy,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FlashcardStudyPage(studySetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.quiz,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return QuizPage(studySetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.quizResult,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return QuizResultPage(studySetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.studyChat,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ChatPage(studySetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);

/// Placeholder page dùng tạm cho các page chưa implement
// ignore: unused_element
class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text(name)),
    );
  }
}

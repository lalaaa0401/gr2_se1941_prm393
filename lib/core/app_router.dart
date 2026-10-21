import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  static const profile        = '/profile';
}

/// go_router singleton
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const _PlaceholderPage('SplashScreen'),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const _PlaceholderPage('LoginPage'),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const _PlaceholderPage('RegisterPage'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _PlaceholderPage('HomeScreen'),
    ),
    GoRoute(
      path: AppRoutes.studySetDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _PlaceholderPage('StudySetDetailPage id=$id');
      },
    ),
    GoRoute(
      path: AppRoutes.flashcardStudy,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _PlaceholderPage('FlashcardStudyPage id=$id');
      },
    ),
    GoRoute(
      path: AppRoutes.quiz,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _PlaceholderPage('QuizPage id=$id');
      },
    ),
    GoRoute(
      path: AppRoutes.quizResult,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _PlaceholderPage('QuizResultPage id=$id');
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const _PlaceholderPage('ProfilePage'),
    ),
  ],
);

/// Placeholder page dùng tạm cho các page chưa implement
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

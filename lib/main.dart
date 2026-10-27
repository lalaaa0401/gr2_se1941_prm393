import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'core/app_router.dart';
import 'core/error_bus.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/study_set_viewmodel.dart';
import 'viewmodels/study_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/progress_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';

/// Key toàn cục để hiển thị SnackBar từ bất kỳ đâu (qua ErrorBus).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => StudySetViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => StudyViewModel(apiService)),
        ChangeNotifierProvider(
            create: (_) => NotificationViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => ProgressViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(apiService)),
      ],
      child: const QuizLabApp(),
    ),
  );
}

class QuizLabApp extends StatefulWidget {
  const QuizLabApp({super.key});

  @override
  State<QuizLabApp> createState() => _QuizLabAppState();
}

class _QuizLabAppState extends State<QuizLabApp> {
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    // Lắng nghe lỗi API và hiển thị SnackBar toàn cục
    _errorSub = ErrorBus.instance.errors.listen((message) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuizLab',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

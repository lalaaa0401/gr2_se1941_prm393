import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'core/app_router.dart';

// ViewModels và Providers sẽ được import khi từng người implement
// Hiện tại để stub để app compile được

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizZoneApp());
}

class QuizZoneApp extends StatelessWidget {
  const QuizZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuizZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

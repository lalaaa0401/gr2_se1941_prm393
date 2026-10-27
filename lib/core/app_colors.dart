import 'package:flutter/material.dart';

/// Toàn bộ màu sắc của QuizLab – v5 palette
class AppColors {
  AppColors._();

  // Background
  static const Color background    = Color(0xFFF5EDE2); // warm cream
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceDim    = Color(0xFFF9F9F9);

  // Text
  static const Color textPrimary   = Color(0xFF1D1D1B);
  static const Color textSecondary = Color(0xFF858494);
  static const Color textDisabled  = Color(0xFFB0B0B0);

  // Border
  static const Color border        = Color(0xFFE8ECF4);
  static const Color borderStrong  = Color(0xFFD1D5DB);

  // Primary – Purple-Indigo
  static const Color primary       = Color(0xFF6A5AE0);
  static const Color primaryLight  = Color(0xFFEDE9FF);
  static const Color primaryMuted  = Color(0xFFC4D0FB);

  // Subject colors – English
  static const Color subjectEnBg   = Color(0xFFEDE9FF);
  static const Color subjectEnText = Color(0xFF6A5AE0);

  // Subject colors – Software Engineering
  static const Color subjectSeBg   = Color(0xFFFFF0E5);
  static const Color subjectSeText = Color(0xFFE89D00);

  // Subject colors – Mobile
  static const Color subjectMoBg   = Color(0xFFE5F6FF);
  static const Color subjectMoText = Color(0xFF354CDF);

  // Subject colors – Math
  static const Color subjectMaBg   = Color(0xFFE5FFE5);
  static const Color subjectMaText = Color(0xFF2E7D32);

  // Known / Unknown flashcard states
  static const Color known         = Color(0xFF2E7D32);
  static const Color knownLight    = Color(0xFFE5FFE5);
  static const Color unknown       = Color(0xFFC9353F);
  static const Color unknownLight  = Color(0xFFFFE8E8);

  // Status
  static const Color success       = Color(0xFF2E7D32);
  static const Color warning       = Color(0xFFE89D00);
  static const Color error         = Color(0xFFC9353F);

  // fl_chart colors
  static const Color chart1        = Color(0xFF6A5AE0);
  static const Color chart2        = Color(0xFF354CDF);
  static const Color chart3        = Color(0xFF2E7D32);
  static const Color chart4        = Color(0xFFE89D00);
  static const Color chart5        = Color(0xFFC9353F);

  /// Trả về màu nền theo môn học
  static Color getSubjectBgColor(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'english':
        return subjectEnBg;
      case 'se':
      case 'software':
        return subjectSeBg;
      case 'mobile':
      case 'flutter':
        return subjectMoBg;
      case 'math':
      case 'toán':
        return subjectMaBg;
      default:
        return primaryLight;
    }
  }

  /// Trả về màu chữ theo môn học
  static Color getSubjectTextColor(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'english':
        return subjectEnText;
      case 'se':
      case 'software':
        return subjectSeText;
      case 'mobile':
      case 'flutter':
        return subjectMoText;
      case 'math':
      case 'toán':
        return subjectMaText;
      default:
        return primary;
    }
  }
}

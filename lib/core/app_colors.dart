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

  /// Trả về màu nền theo môn học — hỗ trợ nhiều subject name từ API
  static Color getSubjectBgColor(String? subject) {
    final s = subject?.toLowerCase().trim() ?? '';
    if (s.contains('english') || s.contains('tiếng anh')) return subjectEnBg;
    if (s.contains('math') || s.contains('toán') || s.contains('discrete')) return subjectMaBg;
    if (s.contains('mobile') || s.contains('flutter') || s.contains('android') || s.contains('ios')) return subjectMoBg;
    if (s.contains('devops') || s.contains('docker') || s.contains('kubernetes') || s.contains('ci/cd')) return subjectMoBg;
    if (s.contains('os') || s.contains('operating') || s.contains('hệ điều hành')) return subjectSeBg;
    if (s.contains('web') || s.contains('javascript') || s.contains('typescript') || s.contains('html') || s.contains('css')) return primaryLight;
    if (s.contains('java') || s.contains('spring') || s.contains('backend') || s.contains('server')) return subjectSeBg;
    if (s.contains('security') || s.contains('bảo mật') || s.contains('network') || s.contains('mạng')) return const Color(0xFFFFE8F0);
    if (s.contains('architect') || s.contains('design') || s.contains('pattern') || s.contains('solid')) return subjectMaBg;
    if (s.contains('database') || s.contains('sql') || s.contains('cơ sở dữ liệu')) return subjectSeBg;
    if (s.contains('se') || s.contains('software')) return subjectSeBg;
    return primaryLight; // fallback
  }

  /// Trả về màu chữ/accent theo môn học
  static Color getSubjectTextColor(String? subject) {
    final s = subject?.toLowerCase().trim() ?? '';
    if (s.contains('english') || s.contains('tiếng anh')) return subjectEnText;
    if (s.contains('math') || s.contains('toán') || s.contains('discrete')) return subjectMaText;
    if (s.contains('mobile') || s.contains('flutter') || s.contains('android') || s.contains('ios')) return subjectMoText;
    if (s.contains('devops') || s.contains('docker') || s.contains('kubernetes') || s.contains('ci/cd')) return subjectMoText;
    if (s.contains('os') || s.contains('operating') || s.contains('hệ điều hành')) return subjectSeText;
    if (s.contains('web') || s.contains('javascript') || s.contains('typescript') || s.contains('html') || s.contains('css')) return primary;
    if (s.contains('java') || s.contains('spring') || s.contains('backend') || s.contains('server')) return subjectSeText;
    if (s.contains('security') || s.contains('bảo mật') || s.contains('network') || s.contains('mạng')) return const Color(0xFFC9353F);
    if (s.contains('architect') || s.contains('design') || s.contains('pattern') || s.contains('solid')) return subjectMaText;
    if (s.contains('database') || s.contains('sql') || s.contains('cơ sở dữ liệu')) return subjectSeText;
    if (s.contains('se') || s.contains('software')) return subjectSeText;
    return primary; // fallback
  }
}

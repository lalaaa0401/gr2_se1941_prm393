import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/progress_viewmodel.dart';

/// Trang hồ sơ người dùng – v5 layout.
///
/// Header cream: avatar vuông initials, tên, email.
/// White sheet: stats row (nếu có), info section, nút đăng xuất.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.currentUser == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: Text(
                  'Chưa đăng nhập',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }
        return _ProfileBody(auth: auth);
      },
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final AuthViewModel auth;
  const _ProfileBody({required this.auth});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  /// Lấy initials từ fullName:
  /// chữ đầu của từ đầu tiên + chữ đầu của từ cuối cùng.
  String _initials(String fullName) {
    final parts =
        fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu tiến độ cho stats row (nếu chưa có)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [A] Cream header — avatar, tên, email
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar vuông 64×64, radius 16, nền primary, initials trắng
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(user.fullName),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // [B] White sheet — nội dung chính
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats row — chỉ hiển thị khi ProgressSummary sẵn sàng
                      Consumer<ProgressViewModel>(
                        builder: (context, progress, _) {
                          final summary = progress.summary;
                          if (summary == null) return const SizedBox.shrink();
                          return _StatsRow(
                            knownCards: summary.totalKnownCards,
                            quizzesTaken: summary.totalQuizzesTaken,
                            avgScore: summary.avgScorePercentage,
                          );
                        },
                      ),

                      // Info section — email và họ tên
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              title: const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              subtitle: Text(user.email, style: AppTextStyles.body),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              title: const Text(
                                'Họ và tên',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              subtitle: Text(user.fullName, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                      ),

                      // Nút đăng xuất
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.unknownLight,
                            foregroundColor: AppColors.unknown,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            await widget.auth.logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                          child: const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hàng 3 stat-card: Thẻ biết / Quiz làm / Điểm TB
class _StatsRow extends StatelessWidget {
  final int knownCards;
  final int quizzesTaken;
  final double avgScore;

  const _StatsRow({
    required this.knownCards,
    required this.quizzesTaken,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (avgScore * 100).round();
    return Row(
      children: [
        _StatCard(label: 'Thẻ biết', value: '$knownCards'),
        const SizedBox(width: 10),
        _StatCard(label: 'Quiz làm', value: '$quizzesTaken'),
        const SizedBox(width: 10),
        _StatCard(label: 'Điểm TB', value: '$pct%'),
      ],
    );
  }
}

/// Mini stat card — nền surfaceDim, radius 16
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

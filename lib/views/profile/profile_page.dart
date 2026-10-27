import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/progress_viewmodel.dart';
import '../../widgets/notification_bell.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgress();
    });
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _relativeTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'hôm nay';
      if (diff.inDays == 1) return 'hôm qua';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${(diff.inDays / 7).floor()} tuần trước';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<AuthViewModel, ProgressViewModel>(
          builder: (context, auth, progress, _) {
            final user = auth.currentUser;
            final summary = progress.summary;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── CREAM HEADER ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    children: [
                      // Bell icon top right
                      Align(
                        alignment: Alignment.centerRight,
                        child: const NotificationBell(),
                      ),
                      const SizedBox(height: 10),
                      // Avatar + name + email
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user != null ? _initials(user.fullName) : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.fullName ?? '—',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '—',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // ── WHITE SHEET ─────────────────────────────────────────
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats row
                          if (summary != null) ...[
                            Row(children: [
                              _StatCard(
                                value: '${summary.totalKnownCards}',
                                label: 'Thẻ biết',
                                isPrimary: true,
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                value: '${summary.totalQuizzesTaken}',
                                label: 'Quiz làm',
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                value:
                                    '${summary.avgScorePercentage.round()}%',
                                label: 'Điểm TB',
                                valueColor: summary.avgScorePercentage >= 60
                                    ? AppColors.known
                                    : summary.avgScorePercentage >= 30
                                        ? AppColors.warning
                                        : AppColors.error,
                              ),
                            ]),
                            const SizedBox(height: 20),
                          ],

                          // Account info
                          _SectionLabel('Tài khoản'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDim,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(children: [
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: user?.email ?? '—',
                              ),
                              const Divider(
                                  height: 1, color: AppColors.border),
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Họ và tên',
                                value: user?.fullName ?? '—',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 20),

                          // Recent activity
                          if (progress.quizHistory.isNotEmpty) ...[
                            _SectionLabel('Hoạt động gần đây'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDim,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: progress.quizHistory
                                    .take(5)
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) => _ActivityRow(
                                          item: e.value,
                                          isLast: e.key ==
                                              (progress.quizHistory.length
                                                          .clamp(0, 5) -
                                                      1),
                                          relativeTime:
                                              _relativeTime(e.value.takenAt),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Logout
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await auth.logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.unknownLight,
                                foregroundColor: AppColors.unknown,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isPrimary;
  final Color? valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    this.isPrimary = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryLight : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.monoLarge.copyWith(
                color: valueColor ??
                    (isPrimary ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      );
}

// ── Info row ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 1),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity row ───────────────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final dynamic item; // QuizHistoryItem
  final bool isLast;
  final String relativeTime;
  const _ActivityRow(
      {required this.item, required this.isLast, required this.relativeTime});

  @override
  Widget build(BuildContext context) {
    final pct = item.percentage.round();
    final color = pct >= 60
        ? AppColors.known
        : pct >= 30
            ? AppColors.warning
            : AppColors.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz đạt $pct% — ${item.studySetTitle}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.score}/${item.totalQuestions} câu đúng',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(relativeTime,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled)),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

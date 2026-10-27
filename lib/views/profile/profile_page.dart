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
  void _showEditModal(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final ctrl = TextEditingController(text: auth.currentUser?.fullName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: auth,
        child: _EditProfileSheet(controller: ctrl),
      ),
    );
  }

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
                          Row(
                            children: [
                              const Expanded(child: _SectionLabel('Tài khoản')),
                              GestureDetector(
                                onTap: () => _showEditModal(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Chỉnh sửa',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

// ── Edit profile bottom sheet ──────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final TextEditingController controller;
  const _EditProfileSheet({required this.controller});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _schoolCtrl = TextEditingController(text: user?.school ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _schoolCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title row
                Row(
                  children: [
                    const Expanded(
                      child: Text('Chỉnh sửa hồ sơ',
                          style: AppTextStyles.h2),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Email (read-only)
                const Text('EMAIL', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  letterSpacing: 0.8, color: AppColors.textSecondary,
                )),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    auth.currentUser?.email ?? '—',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textDisabled),
                  ),
                ),
                const SizedBox(height: 14),
                // Full name
                _sheetField('HỌ VÀ TÊN', widget.controller),
                const SizedBox(height: 12),
                // Phone (optional)
                _sheetField('SỐ ĐIỆN THOẠI (tuỳ chọn)', _phoneCtrl,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                // School (optional)
                _sheetField('TRƯỜNG / TỔ CHỨC (tuỳ chọn)', _schoolCtrl),
                const SizedBox(height: 12),
                // Bio (optional)
                _sheetField('GIỚI THIỆU (tuỳ chọn)', _bioCtrl, maxLines: 3),
                const SizedBox(height: 20),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final name = widget.controller.text.trim();
                            if (name.isEmpty) return;
                    final ok = await auth.updateProfile(
                      name,
                      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
                      school: _schoolCtrl.text.trim().isNotEmpty ? _schoolCtrl.text.trim() : null,
                      bio: _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
                    );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Đã cập nhật hồ sơ'
                                      : (auth.errorMessage ?? 'Lỗi')),
                                  backgroundColor:
                                      ok ? AppColors.success : AppColors.error,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Lưu thay đổi',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ), // Column
            ), // SingleChildScrollView
          ),
        );
      },
    );
  }
}

// ── Reusable field inside sheet ────────────────────────────────────────────────

Widget _sheetField(String label, TextEditingController ctrl,
    {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          letterSpacing: 0.8, color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceDim,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    ],
  );
}

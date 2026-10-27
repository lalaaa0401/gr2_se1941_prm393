import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/home_tab_controller.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/progress_viewmodel.dart';

/// Avatar button — tap để mở quick profile sheet
class AvatarButton extends StatelessWidget {
  const AvatarButton({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.fullName ?? '';
        return GestureDetector(
          onTap: () => _showProfileSheet(context, auth),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileSheet(BuildContext context, AuthViewModel auth) {
    // Capture trước khi mở sheet — sheet builder dùng context khác, không có provider
    final homeTab = context.read<HomeTabController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(
              value: context.read<ProgressViewModel>()),
          ChangeNotifierProvider.value(value: homeTab),
        ],
        child: const _QuickProfileSheet(),
      ),
    );
  }
}

class _QuickProfileSheet extends StatelessWidget {
  const _QuickProfileSheet();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final progress = context.watch<ProgressViewModel>();
    final user = auth.currentUser;
    final summary = progress.summary;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          // Avatar + name + email
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(user?.fullName ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '—', style: AppTextStyles.h2),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '—',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Optional fields (phone, school, bio)
          if (user?.phone != null && user!.phone!.isNotEmpty)
            _InfoRow(icon: Icons.phone_outlined, value: user.phone!),
          if (user?.school != null && user!.school!.isNotEmpty)
            _InfoRow(icon: Icons.school_outlined, value: user.school!),
          if (user?.bio != null && user!.bio!.isNotEmpty)
            _InfoRow(icon: Icons.info_outline, value: user.bio!),

          // Stats mini row
          if (summary != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat('${summary.totalKnownCards}', 'Thẻ biết'),
                _MiniStat('${summary.totalQuizzesTaken}', 'Quiz'),
                _MiniStat('${summary.avgScorePercentage.round()}%', 'Điểm TB'),
                _MiniStat('${summary.currentStreak}🔥', 'Streak'),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Go to full profile button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // đóng sheet trước
                // Chuyển sang tab Hồ sơ (index 3)
                context.read<HomeTabController>().switchTo(3);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryMuted),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Xem hồ sơ đầy đủ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

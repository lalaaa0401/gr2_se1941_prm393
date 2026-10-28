import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/admin.dart';
import '../../models/study_set.dart';
import '../../viewmodels/admin_viewmodel.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
const _kMockActivity = [12, 8, 15, 6, 20, 18, 5];
const List<Color> _kChartColors = [
  AppColors.chart1,
  AppColors.chart2,
  AppColors.chart3,
  AppColors.chart4,
  AppColors.chart5,
];

// ── Admin Page ─────────────────────────────────────────────────────────────────

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            // Loading state
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        vm.errorMessage!,
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.loadAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final stats = vm.stats;
            final pct = (stats != null && stats.totalUsers > 0)
                ? (stats.activeToday / stats.totalUsers).clamp(0.0, 1.0)
                : 0.0;
            final pctInt = (pct * 100).round();

            return DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── CREAM HEADER ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row: back button + title + ADMIN badge
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Quản trị', style: AppTextStyles.h1),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hero card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left — big number + label + badge
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${stats?.totalUsers ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Người dùng',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '✓',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${stats?.activeToday ?? 0} hoạt động hôm nay',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Right — retention ring
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: pct,
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.25),
                                      color: Colors.white,
                                      strokeWidth: 6,
                                      strokeCap: StrokeCap.round,
                                    ),
                                    Center(
                                      child: Text(
                                        '$pctInt%',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mini stats row
                        Row(
                          children: [
                            _MiniCard(
                                value: '${stats?.totalSets ?? 0}',
                                label: 'Bộ học'),
                            const SizedBox(width: 10),
                            _MiniCard(
                                value: '${stats?.totalQuizzes ?? 0}',
                                label: 'Quiz đã làm'),
                            const SizedBox(width: 10),
                            _MiniCard(
                                value: '${stats?.totalUsers ?? 0}',
                                label: 'Người dùng'),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // ── WHITE SHEET ──────────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 2,
                              dividerColor: Colors.transparent,
                              labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                              unselectedLabelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              tabs: const [
                                Tab(text: 'Tổng quan'),
                                Tab(text: 'Người dùng'),
                                Tab(text: 'Bộ học'),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          const Expanded(
                            child: TabBarView(
                              children: [
                                _OverviewTab(),
                                _UsersTab(),
                                _StudySetsTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Mini stat card ─────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  final String value;
  final String label;
  const _MiniCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.monoLarge),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ───────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  Map<String, int> _groupBySubject(List<StudySet> sets) {
    final map = <String, int>{};
    for (final s in sets) {
      final key =
          (s.subject != null && s.subject!.isNotEmpty) ? s.subject! : 'Khác';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        final maxVal = _kMockActivity
            .fold(0, (prev, e) => e > prev ? e : prev)
            .toDouble();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Biểu đồ đăng ký tuần
            const Text('Đăng ký trong tuần', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Container(
              height: 160,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.25,
                  backgroundColor: AppColors.surfaceDim,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= _kDays.length) {
                            return const SizedBox.shrink();
                          }
                          final isToday = i == _kDays.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _kDays[i],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isToday
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isToday
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(_kMockActivity.length, (i) {
                    final isToday = i == _kMockActivity.length - 1;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _kMockActivity[i].toDouble(),
                          color: isToday
                              ? AppColors.warning
                              : AppColors.primaryLight,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Biểu đồ phân bổ chủ đề
            const Text('Phân bổ chủ đề', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            if (vm.studySets.isEmpty)
              const Text('Chưa có dữ liệu', style: AppTextStyles.caption)
            else
              _buildPieSection(vm.studySets),
          ],
        );
      },
    );
  }

  Widget _buildPieSection(List<StudySet> sets) {
    final grouped = _groupBySubject(sets);
    final entries = grouped.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final color = _kChartColors[i % _kChartColors.length];
                return PieChartSectionData(
                  value: entries[i].value.toDouble(),
                  color: color,
                  radius: 55,
                  title: entries[i].key,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(entries.length, (i) {
            final color = _kChartColors[i % _kChartColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(entries[i].key, style: AppTextStyles.caption),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ── Users Tab ──────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmToggleBlock(
      BuildContext context, AdminUser user, AdminViewModel vm) async {
    final wasBlocked = user.isBlocked;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28))),
        title: Text(wasBlocked
            ? 'Mở khoá người dùng?'
            : 'Khoá người dùng?'),
        content: Text(
          wasBlocked
              ? 'Người dùng ${user.fullName} sẽ được mở khoá.'
              : 'Người dùng ${user.fullName} sẽ bị khoá và không thể đăng nhập.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  wasBlocked ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(wasBlocked ? 'Mở khoá' : 'Khoá'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await vm.toggleBlock(user.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasBlocked
              ? 'Đã mở khoá ${user.fullName}'
              : 'Đã khoá ${user.fullName}'),
          backgroundColor:
              wasBlocked ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        final filtered = vm.users
            .where((u) =>
                u.fullName.toLowerCase().contains(_search) ||
                u.email.toLowerCase().contains(_search))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc email',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceDim,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  hintStyle: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Không tìm thấy người dùng',
                      style: AppTextStyles.caption),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) {
                    final user = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: user.isBlocked
                                  ? AppColors.error
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name + email
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: AppTextStyles.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.email,
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Trailing — ADMIN badge, block button, or unblock
                          if (user.role == 'ADMIN')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            )
                          else if (user.isBlocked)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.unknownLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Đã khoá',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () => _confirmToggleBlock(
                                      context, user, vm),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.knownLight,
                                    foregroundColor: AppColors.known,
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'Mở khoá',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            )
                          else
                            ElevatedButton(
                              onPressed: () =>
                                  _confirmToggleBlock(context, user, vm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.unknownLight,
                                foregroundColor: AppColors.error,
                                elevation: 0,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Khoá',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Study Sets Tab ─────────────────────────────────────────────────────────────

class _StudySetsTab extends StatefulWidget {
  const _StudySetsTab();

  @override
  State<_StudySetsTab> createState() => _StudySetsTabState();
}

class _StudySetsTabState extends State<_StudySetsTab> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, StudySet set, AdminViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28))),
        title: const Text('Xoá bộ học?'),
        content: Text('Bộ học "${set.title}" sẽ bị xoá vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await vm.deleteStudySet(set.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xoá bộ học'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        final filtered = vm.studySets
            .where(
                (s) => s.title.toLowerCase().contains(_search))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Tìm bộ học',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceDim,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  hintStyle: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Không tìm thấy bộ học',
                      style: AppTextStyles.caption),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) {
                    final set = filtered[i];
                    final ownerName =
                        set.owner?['fullName'] as String? ?? '—';
                    final dotColor =
                        AppColors.getSubjectTextColor(set.subject);

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // Subject dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title + meta
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  set.title,
                                  style: AppTextStyles.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${set.subject ?? '—'} · $ownerName · ${set.cardCount} thẻ',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Public/private badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: set.isPublic
                                  ? AppColors.knownLight
                                  : null,
                              border: set.isPublic
                                  ? null
                                  : Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              set.isPublic ? 'Công khai' : 'Riêng tư',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: set.isPublic
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          GestureDetector(
                            onTap: () =>
                                _confirmDelete(context, set, vm),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.unknownLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

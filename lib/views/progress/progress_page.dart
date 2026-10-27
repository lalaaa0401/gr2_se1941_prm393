import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/study_progress.dart';
import '../../viewmodels/progress_viewmodel.dart';

/// Màu highlight bar hôm nay — burnt sienna (accent riêng cho chart)
const Color _kTodayColor = Color(0xFFB84A1D);

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ProgressViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.errorMessage!, style: AppTextStyles.body),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.refresh,
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

            final s = vm.summary;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── CREAM HEADER ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiến độ học tập', style: AppTextStyles.h1),
                      const SizedBox(height: 16),
                      if (s != null) ...[
                        _HeroCard(summary: s),
                        const SizedBox(height: 12),
                        _MiniStatsRow(summary: s),
                      ],
                    ],
                  ),
                ),

                // ── WHITE SHEET ───────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: s == null
                        ? const Center(child: Text('Chưa có dữ liệu'))
                        : ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              // Bar chart tuần
                              const Text('Thẻ học trong tuần',
                                  style: AppTextStyles.h2),
                              const SizedBox(height: 12),
                              _WeeklyBarChart(data: s.weeklyActivity),
                              const SizedBox(height: 24),

                              // Per-set progress
                              if (vm.setProgress.isNotEmpty) ...[
                                const Text('Tiến độ từng bộ học',
                                    style: AppTextStyles.h2),
                                const SizedBox(height: 4),
                                ...vm.setProgress.map(
                                    (p) => _SetProgressItem(progress: p)),
                              ],
                            ],
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

// ── Hero card ──────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ProgressSummary summary;
  const _HeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pct = summary.avgScorePercentage.round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left — big number + label + streak badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.totalKnownCards}',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'thẻ đã thuộc',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (summary.currentStreak > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.currentStreak} ngày liên tiếp',
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right — progress ring
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: summary.avgScorePercentage / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  color: Colors.white,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '$pct%',
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
    );
  }
}

// ── Mini stats row ─────────────────────────────────────────────────────────────

class _MiniStatsRow extends StatelessWidget {
  final ProgressSummary summary;
  const _MiniStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final avg = summary.avgScorePercentage.round();
    return Row(
      children: [
        _MiniCard(value: '${summary.totalQuizzesTaken}', label: 'Quiz đã làm'),
        const SizedBox(width: 10),
        _MiniCard(value: '$avg%', label: 'Điểm trung bình'),
        const SizedBox(width: 10),
        _MiniCard(value: '${summary.totalStudySets}', label: 'Bộ học'),
      ],
    );
  }
}

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

// ── Weekly bar chart ───────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyStudy> data;
  const _WeeklyBarChart({required this.data});

  /// 7 ngày cố định nếu data rỗng
  static const _fallback = [
    DailyStudy(day: 'T2', cardsStudied: 0),
    DailyStudy(day: 'T3', cardsStudied: 0),
    DailyStudy(day: 'T4', cardsStudied: 0),
    DailyStudy(day: 'T5', cardsStudied: 0),
    DailyStudy(day: 'T6', cardsStudied: 0),
    DailyStudy(day: 'T7', cardsStudied: 0),
    DailyStudy(day: 'CN', cardsStudied: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final days = data.isEmpty ? _fallback : data;
    // Index của ngày có nhiều thẻ nhất → highlight hôm nay (index cuối cùng != 0)
    int todayIdx = days.length - 1;
    for (int i = days.length - 1; i >= 0; i--) {
      if (days[i].cardsStudied > 0) {
        todayIdx = i;
        break;
      }
    }

    final maxVal = days
        .map((d) => d.cardsStudied.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVal < 5 ? 10 : maxVal * 1.25,
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
                  if (i < 0 || i >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = i == todayIdx;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      days[i].day,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? _kTodayColor : AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(days.length, (i) {
            final isToday = i == todayIdx;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].cardsStudied.toDouble(),
                  color:
                      isToday ? _kTodayColor : AppColors.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Per-set progress item ──────────────────────────────────────────────────────

class _SetProgressItem extends StatelessWidget {
  final StudySetProgress progress;
  const _SetProgressItem({required this.progress});

  Color _barColor(double rate) {
    if (rate >= 0.6) return AppColors.known;
    if (rate >= 0.3) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final rate = progress.completionRate;
    final pct = (rate * 100).round();
    final color = _barColor(rate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.studySetTitle,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.knownCards} / ${progress.totalCards} thẻ biết',
            style: AppTextStyles.caption,
          ),
          const Divider(height: 24, color: AppColors.border),
        ],
      ),
    );
  }
}

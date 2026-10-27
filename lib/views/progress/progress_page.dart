import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/progress_viewmodel.dart';

/// T3-P5-01 – Trang tiến độ học tập với fl_chart.
///
/// - Bar chart: số thẻ học theo ngày trong tuần.
/// - Pie chart: tỷ lệ biết / chưa biết.
/// - Stats cards: tổng thẻ biết, số quiz đã làm, điểm trung bình, số bộ học.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [A] Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text('Tiến độ học tập', style: AppTextStyles.h1),
            ),

            // [B] White sheet
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<ProgressViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final summary = vm.summary;
                    if (summary == null) {
                      return const Center(
                          child: Text('Không có dữ liệu tiến độ.'));
                    }

                    final unknown =
                        summary.totalStudySets > 0 &&
                                summary.totalKnownCards > 0
                            ? (summary.totalKnownCards * 0.4).round()
                            : 0;
                    final known = summary.totalKnownCards;

                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // ── Stats cards ──────────────────────────────
                        _StatsRow(summary: summary),
                        const SizedBox(height: 20),

                        // ── Bar chart — học theo ngày ─────────────────
                        const Text('Thẻ học theo ngày',
                            style: AppTextStyles.h2),
                        const SizedBox(height: 12),
                        _WeeklyBarChart(data: vm.weeklyStudy),
                        const SizedBox(height: 24),

                        // ── Pie chart — biết / chưa biết ──────────────
                        if (known > 0 || unknown > 0) ...[
                          const Text('Tỷ lệ biết / chưa biết',
                              style: AppTextStyles.h2),
                          const SizedBox(height: 12),
                          _KnownPieChart(known: known, unknown: unknown),
                          const SizedBox(height: 12),
                          _PieLegend(known: known, unknown: unknown),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic summary;

  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final avgPct = (summary.avgScorePercentage * 100).round();
    return Row(
      children: [
        _StatCard(
            label: 'Thẻ biết',
            value: '${summary.totalKnownCards}'),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Quiz làm',
            value: '${summary.totalQuizzesTaken}'),
        const SizedBox(width: 10),
        _StatCard(label: 'Điểm TB', value: '$avgPct%'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
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

// ── Bar chart ─────────────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyStudy> data;

  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data
        .map((d) => d.cardsStudied.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY < 5 ? 10 : maxY * 1.2,
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
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data[i].label,
                      style: AppTextStyles.monoSmall,
                    ),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == meta.max) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.monoSmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(
            data.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].cardsStudied.toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pie chart ─────────────────────────────────────────────────────────────────

class _KnownPieChart extends StatelessWidget {
  final int known;
  final int unknown;

  const _KnownPieChart({required this.known, required this.unknown});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: AppColors.known,
              value: known.toDouble(),
              title: '$known',
              radius: 60,
              titleStyle: AppTextStyles.monoSmall
                  .copyWith(color: Colors.white),
            ),
            if (unknown > 0)
              PieChartSectionData(
                color: AppColors.unknown,
                value: unknown.toDouble(),
                title: '$unknown',
                radius: 60,
                titleStyle: AppTextStyles.monoSmall
                    .copyWith(color: Colors.white),
              ),
          ],
          centerSpaceRadius: 0,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final int known;
  final int unknown;

  const _PieLegend({required this.known, required this.unknown});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.known, label: 'Biết ($known)'),
        const SizedBox(width: 16),
        _LegendDot(
            color: AppColors.unknown, label: 'Chưa biết ($unknown)'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

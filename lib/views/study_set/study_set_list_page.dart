import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/progress_viewmodel.dart';
import '../../viewmodels/study_set_viewmodel.dart';
import '../../widgets/study_set_card.dart';

class StudySetListPage extends StatefulWidget {
  const StudySetListPage({super.key});

  @override
  State<StudySetListPage> createState() => _StudySetListPageState();
}

class _StudySetListPageState extends State<StudySetListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudySetViewModel>().loadStudySets();
      // Tải dữ liệu tiến độ cho stats row (safe: loadProgress tự kiểm tra trùng)
      context.read<ProgressViewModel>().loadProgress();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting header trên nền cream ──
            _buildGreetingHeader(),
            // ── Stats row trên nền cream ──
            _buildStatsRow(),
            // ── White sheet chứa search + filter + list ──
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<StudySetViewModel>(
                  builder: (context, vm, _) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Column(
                            children: [
                              // Search field
                              TextField(
                                controller: _searchController,
                                onChanged: vm.searchStudySets,
                                decoration: InputDecoration(
                                  hintText: AppStrings.searchHint,
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
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
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: AppColors.textDisabled,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        // Subject filter chips
                        if (vm.subjects.isNotEmpty) ...[
                          _SubjectFilterRow(
                            subjects: vm.subjects,
                            selectedSubject: vm.selectedSubject,
                            onSelect: vm.filterBySubject,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Expanded(child: _buildBody(context, vm)),
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

  /// Greeting row: LEFT = label UPPERCASE + tên đầy đủ, RIGHT = avatar vuông
  Widget _buildGreetingHeader() {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, _) {
        final user = authVm.currentUser;
        final fullName = user?.fullName ?? 'Bạn';
        final initials = _getInitials(fullName);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phần bên trái: lời chào + tên
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XIN CHÀO 👋',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Phần bên phải: avatar initials
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stats row: 3 mini-card — Thẻ đã biết | Điểm TB quiz | Bộ học
  Widget _buildStatsRow() {
    return Consumer<ProgressViewModel>(
      builder: (context, progressVm, _) {
        final summary = progressVm.summary;

        // Hiển thị "-" khi chưa load xong (null-safe)
        final knownStr =
            summary != null ? '${summary.totalKnownCards}' : '-';
        final avgStr = summary != null
            ? '${(summary.avgScorePercentage * 100).round()}%'
            : '-';
        final setsStr =
            summary != null ? '${summary.totalStudySets}' : '-';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            children: [
              // Card 1: Thẻ đã biết — nền primary
              Expanded(
                child: _MiniStatCard(
                  value: knownStr,
                  label: 'Thẻ đã biết',
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              // Card 2: Điểm TB quiz — nền trắng
              Expanded(
                child: _MiniStatCard(
                  value: avgStr,
                  label: 'Điểm TB quiz',
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              // Card 3: Bộ học — nền trắng
              Expanded(
                child: _MiniStatCard(
                  value: setsStr,
                  label: 'Bộ học',
                  isPrimary: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Lấy initials từ fullName: "Trần Đức" → "TĐ", "Admin" → "A"
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildBody(BuildContext context, StudySetViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => vm.loadStudySets(forceRefresh: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.studySets.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.emptyStudySets,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: vm.studySets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final studySet = vm.studySets[index];
        return StudySetCard(
          studySet: studySet,
          onTap: () => context.go('/study-set/${studySet.id}'),
        );
      },
    );
  }
}

/// Mini stat card dùng trong stats row
class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isPrimary;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectFilterRow extends StatelessWidget {
  final List<String> subjects;
  final String? selectedSubject;
  final void Function(String?) onSelect;

  const _SubjectFilterRow({
    required this.subjects,
    required this.selectedSubject,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: selectedSubject == null,
            onTap: () => onSelect(null),
          ),
          ...subjects.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FilterChip(
                  label: s,
                  isSelected: selectedSubject == s,
                  onTap: () => onSelect(s),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

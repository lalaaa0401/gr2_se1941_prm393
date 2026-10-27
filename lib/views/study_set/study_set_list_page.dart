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
      context.read<ProgressViewModel>().loadProgress();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting (tên + avatar, bỏ label XIN CHÀO) ──
            _buildGreeting(),
            // ── Tiếp tục học ──
            _buildContinueCard(),
            // ── Stats row ──
            _buildStatsRow(),
            // ── White sheet ──
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<StudySetViewModel>(
                  builder: (context, vm, _) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          children: [
                            // Search
                            TextField(
                              controller: _searchController,
                              onChanged: vm.searchStudySets,
                              decoration: InputDecoration(
                                hintText: AppStrings.searchHint,
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
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                hintStyle: const TextStyle(
                                    color: AppColors.textDisabled, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      // Filter chips
                      if (vm.subjects.isNotEmpty) ...[
                        _SubjectFilterRow(
                          subjects: vm.subjects,
                          selectedSubject: vm.selectedSubject,
                          onSelect: vm.filterBySubject,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Expanded(child: _buildList(context, vm)),
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

  /// Tên user + avatar — không có label "XIN CHÀO"
  Widget _buildGreeting() {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.fullName ?? 'Bạn';
        final initials = _getInitials(name);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ),
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

  /// Card tím "Tiếp tục học" — hiện khi có continueSet
  Widget _buildContinueCard() {
    return Consumer<StudySetViewModel>(
      builder: (context, vm, _) {
        final set = vm.continueSet;
        if (set == null) return const SizedBox(height: 14);
        final pct = (set.completionRate * 100).round();
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: GestureDetector(
            onTap: () => context.go('/study/${set.id}/flashcard'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TIẾP TỤC HỌC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          set.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: set.completionRate,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pct% · ${set.knownCards}/${set.cardCount} thẻ',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Học tiếp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Stats row: Thẻ đã biết (primary) | Điểm TB | Streak 🔥
  Widget _buildStatsRow() {
    return Consumer<ProgressViewModel>(
      builder: (context, vm, _) {
        final s = vm.summary;
        final knownStr = s != null ? '${s.totalKnownCards}' : '-';
        final avgStr = s != null
            ? '${(s.avgScorePercentage * 100).round()}%'
            : '-';
        final streakStr = s != null ? '${s.currentStreak}🔥' : '-';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
          child: Row(
            children: [
              Expanded(
                  child: _StatCard(
                      value: knownStr,
                      label: 'Thẻ đã biết',
                      isPrimary: true)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      value: avgStr, label: 'Điểm TB', isPrimary: false)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      value: streakStr,
                      label: 'Streak',
                      isPrimary: false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, StudySetViewModel vm) {
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
              Text(vm.errorMessage!,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadStudySets(forceRefresh: true),
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
        ),
      );
    }
    if (vm.studySets.isEmpty) {
      return const Center(
        child: Text(AppStrings.emptyStudySets,
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: vm.studySets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final set = vm.studySets[i];
        return StudySetCard(
          studySet: set,
          onTap: () => context.go('/study-set/${set.id}'),
        );
      },
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isPrimary;
  const _StatCard(
      {required this.value, required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  isPrimary ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subject filter chips ───────────────────────────────────────────────────────

class _SubjectFilterRow extends StatelessWidget {
  final List<String> subjects;
  final String? selectedSubject;
  final void Function(String?) onSelect;
  const _SubjectFilterRow(
      {required this.subjects,
      required this.selectedSubject,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _Chip(
              label: 'Tất cả',
              isSelected: selectedSubject == null,
              onTap: () => onSelect(null)),
          ...subjects.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _Chip(
                    label: s,
                    isSelected: selectedSubject == s,
                    onTap: () => onSelect(s)),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

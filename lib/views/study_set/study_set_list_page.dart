import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/app_text_styles.dart';
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
            // Header vùng cream
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.homeTitle, style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Tìm và học các bộ flashcard',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // White bottom sheet chứa nội dung
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

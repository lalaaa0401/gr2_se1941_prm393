import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/create_study_set_viewmodel.dart';
import '../../viewmodels/study_set_viewmodel.dart';

/// Màn hình tạo bộ học mới – tab Tạo mới ở HomeScreen.
/// P1 – anhlphe180185 (core) / P3 – ductdhe186732 (study sets)
class CreateStudySetPage extends StatefulWidget {
  const CreateStudySetPage({super.key});

  @override
  State<CreateStudySetPage> createState() => _CreateStudySetPageState();
}

class _CreateStudySetPageState extends State<CreateStudySetPage> {
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();
  final _termController  = TextEditingController();
  final _defController   = TextEditingController();

  static const List<String> _subjects = [
    'English',
    'DevOps',
    'OS',
    'Web Dev',
    'Math',
    'Architecture',
    'Security',
    'Java/Spring',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _termController.dispose();
    _defController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption,
      fillColor: AppColors.surfaceDim,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // ─── Card item ────────────────────────────────────────────────────────────

  Widget _buildCardItem(int i, Map<String, String> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiêu đề thẻ + nút xóa
          Row(
            children: [
              Text('Thẻ ${i + 1}', style: AppTextStyles.label),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    context.read<CreateStudySetViewModel>().removeCard(i),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.unknownLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.unknown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Term | Divider | Definition
          Row(
            children: [
              Expanded(
                child: Text(
                  card['term'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    card['definition'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Add card modal ───────────────────────────────────────────────────────

  void _showAddCardModal(BuildContext context) {
    _termController.clear();
    _defController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Text('Thêm thẻ mới', style: AppTextStyles.h2),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Term field
                Text('THUẬT NGỮ', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: _termController,
                  decoration: _inputDecoration('Thuật ngữ'),
                ),
                const SizedBox(height: 12),
                // Definition field
                Text('ĐỊNH NGHĨA', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: _defController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: _inputDecoration('Định nghĩa'),
                ),
                const SizedBox(height: 20),
                // Thêm thẻ button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final t = _termController.text.trim();
                      final d = _defController.text.trim();
                      if (t.isEmpty || d.isEmpty) return;
                      context
                          .read<CreateStudySetViewModel>()
                          .addCard(t, d);
                      _termController.clear();
                      _defController.clear();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Thêm thẻ'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save(BuildContext context) async {
    final vm = context.read<CreateStudySetViewModel>();
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên bộ học không được để trống'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (vm.cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 thẻ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    vm.setTitle(title);
    vm.setDescription(_descController.text.trim());
    await vm.saveStudySet();

    if (!context.mounted) return;

    if (vm.savedSuccessfully) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo bộ học thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.read<StudySetViewModel>().loadStudySets(forceRefresh: true);
      vm.reset();
      _titleController.clear();
      _descController.clear();
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cream header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: title + subtitle
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tạo bộ học', style: AppTextStyles.h1),
                        SizedBox(height: 4),
                        Text(
                          'Điền thông tin bên dưới',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  // Right: Lưu button
                  ElevatedButton(
                    onPressed: () => _save(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ),

            // ── White sheet ───────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // (1) TÊN BỘ HỌC
                      Text('TÊN BỘ HỌC *', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        decoration:
                            _inputDecoration('Tên bộ học của bạn'),
                      ),

                      // (2) MÔ TẢ
                      const SizedBox(height: 16),
                      Text('MÔ TẢ', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        minLines: 2,
                        decoration:
                            _inputDecoration('Mô tả ngắn về bộ học'),
                      ),

                      // (3) CHỦ ĐỀ chips
                      const SizedBox(height: 16),
                      Text('CHỦ ĐỀ', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Consumer<CreateStudySetViewModel>(
                        builder: (context, vm, _) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _subjects.map((s) {
                              final selected = vm.subject == s;
                              return GestureDetector(
                                onTap: () => vm.setSubject(
                                    selected ? null : s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.surfaceDim,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: selected
                                        ? null
                                        : Border.all(
                                            color: AppColors.border),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      // (4) Công khai switch
                      const SizedBox(height: 16),
                      Consumer<CreateStudySetViewModel>(
                        builder: (context, vm, _) {
                          return Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Công khai',
                                      style: AppTextStyles.h3,
                                    ),
                                    Text(
                                      'Cho phép mọi người tìm thấy',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: vm.isPublic,
                                onChanged: vm.setIsPublic,
                                activeThumbColor: AppColors.primary,
                              ),
                            ],
                          );
                        },
                      ),

                      // (5) Divider
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border),

                      // (6) Thẻ học header + card count
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Thẻ học', style: AppTextStyles.h2),
                          const Spacer(),
                          Consumer<CreateStudySetViewModel>(
                            builder: (context, vm, _) => Text(
                              '${vm.cards.length} thẻ',
                              style: AppTextStyles.mono,
                            ),
                          ),
                        ],
                      ),

                      // (7) Card list
                      const SizedBox(height: 8),
                      Consumer<CreateStudySetViewModel>(
                        builder: (context, vm, _) {
                          return Column(
                            children: vm.cards
                                .asMap()
                                .entries
                                .map((e) =>
                                    _buildCardItem(e.key, e.value))
                                .toList(),
                          );
                        },
                      ),

                      // (8) Thêm thẻ mới button
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showAddCardModal(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            '+ Thêm thẻ mới',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      // (9) Bottom spacing
                      const SizedBox(height: 24),
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

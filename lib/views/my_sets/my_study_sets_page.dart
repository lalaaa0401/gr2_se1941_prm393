import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../models/study_set.dart';
import '../../viewmodels/my_study_sets_viewmodel.dart';

/// Màn hình quản lý bộ học cá nhân — tab index 2
/// P3 — ductdhe186732
class MyStudySetsPage extends StatefulWidget {
  const MyStudySetsPage({super.key});

  @override
  State<MyStudySetsPage> createState() => _MyStudySetsPageState();
}

class _MyStudySetsPageState extends State<MyStudySetsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MyStudySetsViewModel>().loadMySets();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border_rounded,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('Chưa có bộ học nào',
              style:
                  AppTextStyles.h2.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Tạo bộ học đầu tiên của bạn',
              style: AppTextStyles.caption),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await context.push(AppRoutes.createSet);
              if (mounted) {
                context.read<MyStudySetsViewModel>().loadMySets();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tạo bộ học đầu tiên'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyStudySetsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cream header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bộ học của tôi', style: AppTextStyles.h1),
                      SizedBox(height: 4),
                      Text('Quản lý bộ thẻ của bạn',
                          style: AppTextStyles.caption),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context
                        .push(AppRoutes.createSet)
                        .then((_) => vm.loadMySets()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('＋ Tạo mới'),
                  ),
                ],
              ),
            ),

            // ── White sheet ───────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<MyStudySetsViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }
                    if (vm.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(vm.errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: vm.loadMySets,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (vm.sets.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: vm.sets.length,
                      itemBuilder: (_, i) =>
                          _MySetTile(set: vm.sets[i], vm: vm),
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

// ─── _MySetTile ─────────────────────────────────────────────────────────────

class _MySetTile extends StatelessWidget {
  final StudySet set;
  final MyStudySetsViewModel vm;

  const _MySetTile({required this.set, required this.vm});

  void _togglePublic(BuildContext context) async {
    final newValue = !set.isPublic;
    final ok = await vm.updateSet(set.id, set.title,
        description: set.description,
        subject: set.subject,
        isPublic: newValue);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (newValue ? 'Đã đặt công khai' : 'Đã đặt riêng tư')
            : (vm.errorMessage ?? 'Lỗi cập nhật')),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Xóa bộ học'),
        content: Text(
            'Bạn có chắc muốn xóa "${set.title}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await vm.deleteSet(set.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      ok ? 'Đã xóa bộ học' : (vm.errorMessage ?? 'Lỗi xóa')),
                  backgroundColor:
                      ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getSubjectBgColor(set.subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Subject label + public/private badge
            Row(
              children: [
                if (set.subject != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      set.subject!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  set.isPublic ? Icons.public : Icons.lock,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  set.isPublic ? 'Công khai' : 'Riêng tư',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Title
            Text(
              set.title,
              style: AppTextStyles.h2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Row 3: Card count
            Text('${set.cardCount} thẻ', style: AppTextStyles.caption),
            const SizedBox(height: 12),

            // Row 4: Progress bar
            LinearProgressIndicator(
              value: set.completionRate,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
              minHeight: 4,
            ),
            const SizedBox(height: 12),

            // Row 5: Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  onTap: () =>
                      showEditStudySetSheet(context, set, vm),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: set.isPublic
                      ? Icons.public
                      : Icons.lock_outline,
                  onTap: () => _togglePublic(context),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ActionButton ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ─── showEditStudySetSheet ────────────────────────────────────────────────────

void showEditStudySetSheet(
    BuildContext context, StudySet set, MyStudySetsViewModel vm) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditSetSheet(set: set, vm: vm),
  );
}

// ─── _EditSetSheet ────────────────────────────────────────────────────────────

class _EditSetSheet extends StatefulWidget {
  final StudySet set;
  final MyStudySetsViewModel vm;

  const _EditSetSheet({required this.set, required this.vm});

  @override
  State<_EditSetSheet> createState() => _EditSetSheetState();
}

class _EditSetSheetState extends State<_EditSetSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String? _subject;
  bool _isPublic = true;
  bool _isSaving = false;

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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.set.title);
    _descController =
        TextEditingController(text: widget.set.description ?? '');
    _subject = widget.set.subject;
    _isPublic = widget.set.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption,
      fillColor: AppColors.surfaceDim,
      filled: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tên bộ học không được để trống'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _isSaving = true);
    final ok = await widget.vm.updateSet(
      widget.set.id,
      title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      subject: _subject,
      isPublic: _isPublic,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          ok ? 'Đã lưu thay đổi' : (widget.vm.errorMessage ?? 'Lỗi lưu')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
    if (ok) Navigator.pop(context);
  }

  void _showEditCardDialog(BuildContext context, Flashcard card) {
    final termCtrl = TextEditingController(text: card.term);
    final defCtrl = TextEditingController(text: card.definition);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Chỉnh sửa thẻ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: termCtrl,
              decoration: const InputDecoration(labelText: 'Thuật ngữ'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: defCtrl,
              decoration: const InputDecoration(labelText: 'Định nghĩa'),
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              termCtrl.dispose();
              defCtrl.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final t = termCtrl.text.trim();
              final d = defCtrl.text.trim();
              if (t.isEmpty || d.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await widget.vm
                  .updateFlashcard(card.id, t, d, card.position);
              termCtrl.dispose();
              defCtrl.dispose();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Đã cập nhật thẻ'
                      : (widget.vm.errorMessage ?? 'Lỗi')),
                  backgroundColor:
                      ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard(BuildContext context, int cardId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Xóa thẻ'),
        content: const Text(
            'Bạn có chắc muốn xóa thẻ này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await widget.vm.deleteFlashcard(cardId, widget.set.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Đã xóa thẻ'
                      : (widget.vm.errorMessage ?? 'Lỗi xóa thẻ')),
                  backgroundColor:
                      ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddCardModal(BuildContext context) {
    final termCtrl = TextEditingController();
    final defCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
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
                Row(
                  children: [
                    Text('Thêm thẻ mới', style: AppTextStyles.h2),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        termCtrl.dispose();
                        defCtrl.dispose();
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('THUẬT NGỮ', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                    controller: termCtrl,
                    decoration: _inputDecoration('Thuật ngữ')),
                const SizedBox(height: 12),
                Text('ĐỊNH NGHĨA', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: defCtrl,
                  maxLines: 3,
                  minLines: 2,
                  decoration: _inputDecoration('Định nghĩa'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final t = termCtrl.text.trim();
                      final d = defCtrl.text.trim();
                      if (t.isEmpty || d.isEmpty) return;
                      Navigator.pop(ctx);
                      final ok = await widget.vm
                          .addFlashcard(widget.set.id, t, d);
                      termCtrl.dispose();
                      defCtrl.dispose();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Đã thêm thẻ mới'
                              : (widget.vm.errorMessage ?? 'Lỗi thêm thẻ')),
                          backgroundColor:
                              ok ? AppColors.success : AppColors.error,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
            child: Row(
              children: [
                Text('Chỉnh sửa bộ học', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TÊN BỘ HỌC
                  Text('TÊN BỘ HỌC *', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration('Tên bộ học của bạn'),
                  ),

                  // MÔ TẢ
                  const SizedBox(height: 16),
                  Text('MÔ TẢ', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: _inputDecoration('Mô tả ngắn về bộ học'),
                  ),

                  // CHỦ ĐỀ chips
                  const SizedBox(height: 16),
                  Text('CHỦ ĐỀ', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _subjects.map((s) {
                      final selected = _subject == s;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _subject = selected ? null : s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surfaceDim,
                            borderRadius: BorderRadius.circular(20),
                            border: selected
                                ? null
                                : Border.all(color: AppColors.border),
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
                  ),

                  // Công khai switch
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Công khai', style: AppTextStyles.h3),
                            Text('Cho phép mọi người tìm thấy',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPublic,
                        onChanged: (v) => setState(() => _isPublic = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),

                  // Nút Lưu
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Lưu thay đổi'),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Flashcard section — dùng Consumer để tự rebuild khi vm notify
                  Consumer<MyStudySetsViewModel>(
                    builder: (context, vm, _) {
                      // Lấy set mới nhất từ vm để phản ánh thay đổi realtime
                      final currentSet = vm.sets.firstWhere(
                        (s) => s.id == widget.set.id,
                        orElse: () => widget.set,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Thẻ học (${currentSet.flashcards.length})',
                                style: AppTextStyles.h2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...currentSet.flashcards.map((card) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDim,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.term,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          card.definition,
                                          style: AppTextStyles.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.primary),
                                    onPressed: () =>
                                        _showEditCardDialog(context, card),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18,
                                        color: AppColors.error),
                                    onPressed: () =>
                                        _confirmDeleteCard(context, card.id),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showAddCardModal(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text(
                                '＋ Thêm thẻ mới',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

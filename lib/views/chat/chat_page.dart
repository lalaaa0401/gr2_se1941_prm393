import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/app_text_styles.dart';
import '../../models/message.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';

class ChatPage extends StatefulWidget {
  final int studySetId;
  const ChatPage({super.key, required this.studySetId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  static final _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadMessages(widget.studySetId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send(ChatViewModel vm) async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    _controller.clear();
    await vm.sendMessage(widget.studySetId, content);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bình luận', style: AppTextStyles.h1),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              Expanded(child: _buildBody(context, vm)),
              _InputRow(
                controller: _controller,
                isSending: vm.isSending,
                onSend: () => _send(vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.messages.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.emptyMessages,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final currentUserId =
        context.read<AuthViewModel>().currentUser?.id;
    return ListView.builder(
      controller: _scrollController,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.messages.length,
      itemBuilder: (context, index) {
        final msg = vm.messages[index];
        return _MessageBubble(
          message: msg,
          isOwn: msg.senderId == currentUserId,
          timeFormat: _timeFormat,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwn;
  final DateFormat timeFormat;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.timeFormat,
  });

  String _formatTime(String? sentAt) {
    if (sentAt == null) return '';
    try {
      return timeFormat.format(DateTime.parse(sentAt));
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isOwn ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isOwn)
              Text(
                message.senderName,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.primary),
              ),
            if (!isOwn) const SizedBox(height: 2),
            Text(
              message.content,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.sentAt),
              style: AppTextStyles.monoSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputRow({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Nhắn tin...',
                hintStyle: const TextStyle(
                    color: AppColors.textDisabled, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

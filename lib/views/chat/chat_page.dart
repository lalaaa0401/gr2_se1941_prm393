import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final int studySetId;
  const ChatPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(child: Text('ChatPage #$studySetId – coming soon')),
    );
  }
}

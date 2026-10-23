class Message {
  final int id;
  final String content;
  final String? sentAt;
  final Map<String, dynamic> sender;

  Message({
    required this.id,
    required this.content,
    this.sentAt,
    required this.sender,
  });

  int get senderId => sender['id'];
  String get senderName => sender['fullName'] ?? '';
  String? get senderAvatar => sender['avatarUrl'];

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    sentAt: json['sentAt'],
    sender: json['sender'],
  );

  Map<String, dynamic> toJson() => {'content': content};
}

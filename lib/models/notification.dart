class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    type: json['type'] ?? 'INFO',
    isRead: json['isRead'] ?? false,
    createdAt: json['createdAt'],
  );
}

/// Model cho thống kê tổng quan của admin
class AdminStats {
  final int totalUsers;
  final int totalSets;
  final int totalQuizzes;
  final int activeToday;

  const AdminStats({
    required this.totalUsers,
    required this.totalSets,
    required this.totalQuizzes,
    required this.activeToday,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalUsers: (json['totalUsers'] ?? 0) as int,
    totalSets: (json['totalSets'] ?? 0) as int,
    totalQuizzes: (json['totalQuizzes'] ?? 0) as int,
    activeToday: (json['activeToday'] ?? 0) as int,
  );
}

/// Model cho người dùng khi xem từ góc độ admin
class AdminUser {
  final int id;
  final String email;
  final String fullName;
  final String? role;
  final bool isBlocked;
  final String? phone;
  final String? school;

  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.role,
    this.isBlocked = false,
    this.phone,
    this.school,
  });

  /// Chữ viết tắt từ fullName — dùng cho avatar
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'],
    email: json['email'],
    fullName: json['fullName'],
    role: json['role'],
    isBlocked: json['isBlocked'] ?? false,
    phone: json['phone'],
    school: json['school'],
  );

  AdminUser copyWith({bool? isBlocked}) => AdminUser(
    id: id,
    email: email,
    fullName: fullName,
    role: role,
    isBlocked: isBlocked ?? this.isBlocked,
    phone: phone,
    school: school,
  );
}

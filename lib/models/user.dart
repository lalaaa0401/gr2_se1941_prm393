class User {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? token;
  final String? phone;
  final String? school;
  final String? bio;
  final String? role;
  final bool isBlocked;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.token,
    this.phone,
    this.school,
    this.bio,
    this.role,
    this.isBlocked = false,
  });

  /// true nếu user có role ADMIN
  bool get isAdmin => role == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['userId'] ?? json['id'],
    email: json['email'],
    fullName: json['fullName'],
    avatarUrl: json['avatarUrl'],
    token: json['token'],
    phone: json['phone'],
    school: json['school'],
    bio: json['bio'],
    role: json['role'],
    isBlocked: json['isBlocked'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    if (phone != null) 'phone': phone,
    if (school != null) 'school': school,
    if (bio != null) 'bio': bio,
  };
}

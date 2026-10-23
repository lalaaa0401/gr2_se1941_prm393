class User {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['userId'] ?? json['id'],
    email: json['email'],
    fullName: json['fullName'],
    avatarUrl: json['avatarUrl'],
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
  };
}

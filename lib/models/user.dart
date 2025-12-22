import 'package:intl/intl.dart';

class User {
  int? id;
  String email;
  String password;
  String name;
  String? avatarUrl;
  DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      avatarUrl: map['avatar_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);
}

// ============================================================================
// Reemplazar UserModel completo en user_model.dart
// ============================================================================

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String email;
  final String name;
  final String avatarEmoji;
  final String? bio;
  final int? age;
  final String? profilePicturePath;
  final bool isFirstTimeUser;
  final Map<String, dynamic> preferences;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserModel({
    this.id,
    required this.email,
    required this.name,
    this.avatarEmoji = '🧘‍♀️',
    this.bio,
    this.age,
    this.profilePicturePath,
    this.isFirstTimeUser = true,
    this.preferences = const {},
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Método para crear usuario desde base de datos
  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      name: map['name'] as String,
      avatarEmoji: map['avatar_emoji'] as String? ?? '🧘‍♀️',
      bio: map['bio'] as String?,
      age: map['age'] as int?,
      profilePicturePath: map['profile_picture_path'] as String?,
      isFirstTimeUser: (map['is_first_time_user'] as int? ?? 1) == 1,
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(json.decode(map['preferences']))
          : {},
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  // Método para convertir a base de datos
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'bio': bio,
      'age': age,
      'profile_picture_path': profilePicturePath,
      'is_first_time_user': isFirstTimeUser ? 1 : 0,
      'preferences': json.encode(preferences),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? avatarEmoji,
    String? bio,
    int? age,
    String? profilePicturePath,
    bool? isFirstTimeUser,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
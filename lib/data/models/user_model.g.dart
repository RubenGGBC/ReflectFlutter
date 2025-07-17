// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      avatarEmoji: json['avatarEmoji'] as String? ?? '🧘‍♀️',
      bio: json['bio'] as String?,
      age: (json['age'] as num?)?.toInt(),
      profilePicturePath: json['profilePicturePath'] as String?,
      isFirstTimeUser: json['isFirstTimeUser'] as bool? ?? true,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatarEmoji': instance.avatarEmoji,
      'bio': instance.bio,
      'age': instance.age,
      'profilePicturePath': instance.profilePicturePath,
      'isFirstTimeUser': instance.isFirstTimeUser,
      'preferences': instance.preferences,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLogin': instance.lastLogin?.toIso8601String(),
    };

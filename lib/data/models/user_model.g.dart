// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      bio: json['bio'] as String?,
      totalBooksRead: (json['totalBooksRead'] as num?)?.toInt() ?? 0,
      totalReadingTime: (json['totalReadingTime'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      isPremium: json['isPremium'] as bool? ?? false,
      language: json['language'] as String? ?? 'ko',
      themeMode: json['themeMode'] as String? ?? 'light',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
      dailyReadingGoal: (json['dailyReadingGoal'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'phoneNumber': instance.phoneNumber,
      'birthDate': instance.birthDate?.toIso8601String(),
      'bio': instance.bio,
      'totalBooksRead': instance.totalBooksRead,
      'totalReadingTime': instance.totalReadingTime,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'isPremium': instance.isPremium,
      'language': instance.language,
      'themeMode': instance.themeMode,
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotificationsEnabled': instance.emailNotificationsEnabled,
      'dailyReadingGoal': instance.dailyReadingGoal,
    };

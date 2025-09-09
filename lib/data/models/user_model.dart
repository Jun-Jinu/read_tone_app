import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? birthDate,
    String? bio,
    @Default(0) int totalBooksRead,
    @Default(0) int totalReadingTime,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastLoginAt,
    @Default(false) bool isPremium,
    @Default('ko') String language,
    @Default('light') String themeMode,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotificationsEnabled,
    @Default(30) int dailyReadingGoal,
  }) = _UserModel;

  const UserModel._();

  /// JSON 직렬화
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// User 엔티티로 변환
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      bio: bio,
      totalBooksRead: totalBooksRead,
      totalReadingTime: totalReadingTime,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
      isPremium: isPremium,
      language: language,
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      dailyReadingGoal: dailyReadingGoal,
    );
  }

  /// User 엔티티에서 변환
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      profileImageUrl: user.profileImageUrl,
      phoneNumber: user.phoneNumber,
      birthDate: user.birthDate,
      bio: user.bio,
      totalBooksRead: user.totalBooksRead,
      totalReadingTime: user.totalReadingTime,
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
      isPremium: user.isPremium,
      language: user.language,
      themeMode: user.themeMode,
      notificationsEnabled: user.notificationsEnabled,
      emailNotificationsEnabled: user.emailNotificationsEnabled,
      dailyReadingGoal: user.dailyReadingGoal,
    );
  }

  /// Firebase Firestore 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'bio': bio,
      'totalBooksRead': totalBooksRead,
      'totalReadingTime': totalReadingTime,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isPremium': isPremium,
      'language': language,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'dailyReadingGoal': dailyReadingGoal,
    };
  }

  /// Firebase Firestore에서 변환
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      birthDate: data['birthDate'] != null
          ? DateTime.parse(data['birthDate'] as String)
          : null,
      bio: data['bio'] as String?,
      totalBooksRead: data['totalBooksRead'] as int? ?? 0,
      totalReadingTime: data['totalReadingTime'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.parse(data['lastLoginAt'] as String)
          : null,
      isPremium: data['isPremium'] as bool? ?? false,
      language: data['language'] as String? ?? 'ko',
      themeMode: data['themeMode'] as String? ?? 'light',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          data['emailNotificationsEnabled'] as bool? ?? true,
      dailyReadingGoal: data['dailyReadingGoal'] as int? ?? 30,
    );
  }

  /// 로컬 데이터베이스용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'bio': bio,
      'totalBooksRead': totalBooksRead,
      'totalReadingTime': totalReadingTime,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isPremium': isPremium ? 1 : 0,
      'language': language,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'emailNotificationsEnabled': emailNotificationsEnabled ? 1 : 0,
      'dailyReadingGoal': dailyReadingGoal,
    };
  }

  /// 로컬 데이터베이스에서 변환
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : null,
      bio: map['bio'] as String?,
      totalBooksRead: map['totalBooksRead'] as int? ?? 0,
      totalReadingTime: map['totalReadingTime'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      isPremium: (map['isPremium'] as int?) == 1,
      language: map['language'] as String? ?? 'ko',
      themeMode: map['themeMode'] as String? ?? 'light',
      notificationsEnabled: (map['notificationsEnabled'] as int?) == 1,
      emailNotificationsEnabled:
          (map['emailNotificationsEnabled'] as int?) == 1,
      dailyReadingGoal: map['dailyReadingGoal'] as int? ?? 30,
    );
  }
}

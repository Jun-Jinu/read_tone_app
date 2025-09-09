import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? birthDate,
    String? bio,
    @Default(0) int totalBooksRead,
    @Default(0) int totalReadingTime, // 분 단위
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
    @Default(30) int dailyReadingGoal, // 분 단위
  }) = _User;

  const User._();

  /// 사용자 이름 반환 (displayName이 없으면 이메일에서 추출)
  String get name => displayName ?? email.split('@')[0];

  /// 프로필 이미지 URL 반환 (없으면 기본 아바타)
  String get profileImage => profileImageUrl ?? '';

  /// 독서 목표 달성률 계산
  double get dailyGoalProgress {
    // 실제로는 오늘의 독서 시간과 비교해야 하지만, 여기서는 예시로 0.0 반환
    return 0.0;
  }

  /// 나이 계산
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// 가입 기간 (일 단위)
  int get membershipDays {
    return DateTime.now().difference(createdAt).inDays;
  }
}

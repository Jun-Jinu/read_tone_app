import '../../domain/entities/user.dart';

abstract class UserLocalDataSource {
  /// 현재 로그인된 사용자 정보 가져오기
  Future<User?> getCurrentUser();

  /// 사용자 정보 저장/업데이트
  Future<void> saveUser(User user);

  /// 사용자 정보 업데이트
  Future<void> updateUser(User user);

  /// 사용자 정보 삭제
  Future<void> deleteUser(String uid);

  /// 모든 사용자 데이터 지우기 (로그아웃 시)
  Future<void> clearAllUserData();

  /// 사용자 존재 여부 확인
  Future<bool> userExists(String uid);

  /// 사용자 설정 업데이트
  Future<void> updateUserSettings({
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    int? dailyReadingGoal,
  });

  /// 독서 통계 업데이트
  Future<void> updateReadingStats({
    int? totalBooksRead,
    int? totalReadingTime,
    int? currentStreak,
    int? longestStreak,
  });
}

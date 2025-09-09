import '../entities/user.dart';

abstract class UserRepository {
  /// 현재 사용자 스트림
  Stream<User?> get currentUserStream;

  /// 로그인 상태 확인
  bool get isLoggedIn;

  /// 현재 사용자 정보
  Future<User?> getCurrentUser();

  /// 이메일/비밀번호로 회원가입
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// 이메일/비밀번호로 로그인
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 구글 로그인
  Future<User> signInWithGoogle();

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email);

  /// 사용자 정보 업데이트
  Future<User> updateUser(User user);

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

  /// 프로필 이미지 업데이트
  Future<void> updateProfileImage(String imageUrl);

  /// 계정 삭제
  Future<void> deleteAccount();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/datasources/user_local_data_source_impl.dart';

// AuthState 정의
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isLoggedIn;
  final bool isGuest;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isLoggedIn = false,
    this.isGuest = false,
  });

  // 호환성을 위한 getter들
  bool get isAuthenticated => isLoggedIn;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isLoggedIn,
    bool? isGuest,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    authService: FirebaseAuthService(),
    localDataSource: UserLocalDataSourceImpl(),
  );
});

// AuthNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthNotifier(this._userRepository) : super(const AuthState()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    debugPrint('AuthNotifier: 인증 상태 초기화 시작');

    // 사용자 상태 스트림 구독
    _userRepository.currentUserStream.listen((user) {
      debugPrint(
          'AuthNotifier: 사용자 상태 변경 - ${user != null ? '로그인됨 (${user.email})' : '로그아웃됨'}');

      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: user != null,
        isGuest: false,
        error: null,
      );
    });
  }

  // 이메일/비밀번호로 회원가입
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    debugPrint('AuthNotifier: 회원가입 시도 - 이메일: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _userRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      debugPrint('AuthNotifier: 회원가입 성공');
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      debugPrint('AuthNotifier: 회원가입 실패 - $e');
      state = state.copyWith(isLoading: false, error: null);
      rethrow;
    }
  }

  // 이메일/비밀번호로 로그인
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('AuthNotifier: 로그인 시도 - 이메일: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _userRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('AuthNotifier: 로그인 성공');
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      debugPrint('AuthNotifier: 로그인 실패 - $e');
      state = state.copyWith(isLoading: false, error: null);
      rethrow;
    }
  }

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _userRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: null);
      rethrow;
    }
  }

  // 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _userRepository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // 게스트 모드로 계속
  Future<void> continueAsGuest() async {
    debugPrint('AuthNotifier: 게스트 모드로 계속하기');
    state = state.copyWith(
      isLoading: false,
      user: null,
      isLoggedIn: false,
      isGuest: true,
      error: null,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _userRepository.signOut();
      state = state.copyWith(
        isLoading: false,
        user: null,
        isLoggedIn: false,
        isGuest: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 호환성을 위한 logout 메서드 (signOut과 동일)
  Future<void> logout() async {
    await signOut();
  }

  // 사용자 정보 업데이트
  Future<void> updateUser(User user) async {
    try {
      await _userRepository.updateUser(user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // 사용자 설정 업데이트
  Future<void> updateUserSettings({
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    int? dailyReadingGoal,
  }) async {
    try {
      await _userRepository.updateUserSettings(
        language: language,
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        dailyReadingGoal: dailyReadingGoal,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 독서 통계 업데이트
  Future<void> updateReadingStats({
    int? totalBooksRead,
    int? totalReadingTime,
    int? currentStreak,
    int? longestStreak,
  }) async {
    try {
      await _userRepository.updateReadingStats(
        totalBooksRead: totalBooksRead,
        totalReadingTime: totalReadingTime,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 프로필 이미지 업데이트
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      await _userRepository.updateProfileImage(imageUrl);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    try {
      await _userRepository.deleteAccount();
      state = state.copyWith(
        user: null,
        isLoggedIn: false,
        isGuest: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // 에러 상태 지우기
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// AuthProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(userRepository);
});

// 편의 Provider들
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isGuest;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

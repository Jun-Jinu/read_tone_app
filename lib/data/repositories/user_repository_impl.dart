import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService _authService;
  final UserLocalDataSource _localDataSource;

  late final StreamController<User?> _userStreamController;
  late final StreamSubscription _authSubscription;

  UserRepositoryImpl({
    required FirebaseAuthService authService,
    required UserLocalDataSource localDataSource,
  })  : _authService = authService,
        _localDataSource = localDataSource {
    _userStreamController = StreamController<User?>.broadcast();
    _initializeUserStream();
  }

  void _initializeUserStream() {
    debugPrint('UserRepository: 사용자 스트림 초기화');

    _authSubscription =
        _authService.authStateChanges.listen((firebaseUser) async {
      debugPrint(
          'UserRepository: Firebase 인증 상태 변경 - ${firebaseUser != null ? '사용자 있음 (${firebaseUser.email})' : '사용자 없음'}');

      if (firebaseUser != null) {
        try {
          debugPrint('UserRepository: Firebase에서 사용자 정보 가져오기 시도');
          // Firebase에서 사용자 정보 가져오기
          final user = await _authService.getCurrentUser();
          if (user != null) {
            debugPrint(
                'UserRepository: Firebase에서 사용자 정보 가져오기 성공 - ${user.email}');
            // 로컬에 캐시
            await _localDataSource.saveUser(user);
            _userStreamController.add(user);
          }
        } catch (e) {
          debugPrint('UserRepository: Firebase에서 사용자 정보 가져오기 실패 - $e');
          // Firebase에서 실패하면 로컬에서 가져오기
          final localUser = await _localDataSource.getCurrentUser();
          debugPrint(
              'UserRepository: 로컬에서 사용자 정보 가져오기 ${localUser != null ? '성공' : '실패'}');
          _userStreamController.add(localUser);
        }
      } else {
        debugPrint('UserRepository: 로그아웃 상태 - 로컬 데이터 정리');
        // 로그아웃 상태
        await _localDataSource.clearAllUserData();
        _userStreamController.add(null);
      }
    });
  }

  @override
  Stream<User?> get currentUserStream => _userStreamController.stream;

  @override
  bool get isLoggedIn => _authService.isLoggedIn;

  @override
  Future<User?> getCurrentUser() async {
    try {
      // 먼저 Firebase에서 가져오기 시도
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // 로컬에 캐시
        await _localDataSource.saveUser(user);
        return user;
      }
    } catch (e) {
      // Firebase에서 실패하면 로컬에서 가져오기
      return await _localDataSource.getCurrentUser();
    }
    return null;
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    // 로컬에 저장
    await _localDataSource.saveUser(user);

    return user;
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('UserRepository: 로그인 시도 - $email');

    final user = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('user: $user');

    debugPrint('UserRepository: Firebase 로그인 성공, 로컬에 저장 중');
    // 로컬에 저장
    await _localDataSource.saveUser(user);

    debugPrint('UserRepository: 로그인 완료 - ${user.email}');
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();

    // 로컬에 저장
    await _localDataSource.saveUser(user);

    return user;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    // 로컬 데이터는 authStateChanges에서 자동으로 정리됨
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      // Firebase 업데이트
      final updatedUser = await _authService.updateUser(user);

      // 로컬 업데이트
      await _localDataSource.updateUser(updatedUser);

      return updatedUser;
    } catch (e) {
      // Firebase 실패시 로컬만 업데이트
      await _localDataSource.updateUser(user);
      return user;
    }
  }

  @override
  Future<void> updateUserSettings({
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    int? dailyReadingGoal,
  }) async {
    // 로컬 업데이트
    await _localDataSource.updateUserSettings(
      language: language,
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      dailyReadingGoal: dailyReadingGoal,
    );

    // Firebase 업데이트 시도
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          language: language ?? currentUser.language,
          themeMode: themeMode ?? currentUser.themeMode,
          notificationsEnabled:
              notificationsEnabled ?? currentUser.notificationsEnabled,
          emailNotificationsEnabled: emailNotificationsEnabled ??
              currentUser.emailNotificationsEnabled,
          dailyReadingGoal: dailyReadingGoal ?? currentUser.dailyReadingGoal,
          updatedAt: DateTime.now(),
        );

        await _authService.updateUser(updatedUser);
      }
    } catch (e) {
      // Firebase 업데이트 실패는 무시 (로컬은 이미 업데이트됨)
    }
  }

  @override
  Future<void> updateReadingStats({
    int? totalBooksRead,
    int? totalReadingTime,
    int? currentStreak,
    int? longestStreak,
  }) async {
    // 로컬 업데이트
    await _localDataSource.updateReadingStats(
      totalBooksRead: totalBooksRead,
      totalReadingTime: totalReadingTime,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );

    // Firebase 업데이트 시도
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          totalBooksRead: totalBooksRead ?? currentUser.totalBooksRead,
          totalReadingTime: totalReadingTime ?? currentUser.totalReadingTime,
          currentStreak: currentStreak ?? currentUser.currentStreak,
          longestStreak: longestStreak ?? currentUser.longestStreak,
          updatedAt: DateTime.now(),
        );

        await _authService.updateUser(updatedUser);
      }
    } catch (e) {
      // Firebase 업데이트 실패는 무시
    }
  }

  @override
  Future<void> updateProfileImage(String imageUrl) async {
    await _authService.updateProfileImage(imageUrl);

    // 로컬 업데이트
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );
      await _localDataSource.updateUser(updatedUser);
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    // 로컬 데이터는 authStateChanges에서 자동으로 정리됨
  }

  void dispose() {
    _authSubscription.cancel();
    _userStreamController.close();
  }
}

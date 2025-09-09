import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// 현재 사용자 스트림
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// 현재 로그인된 사용자
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// 현재 사용자 UID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// 로그인 상태 확인
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// 익명 사용자인지 확인
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? false;

  /// 이메일/비밀번호로 회원가입
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Firebase Authentication에 사용자 생성
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('사용자 생성에 실패했습니다');
      }

      // displayName 설정
      if (displayName != null && displayName.isNotEmpty) {
        await firebaseUser.updateDisplayName(displayName);
      }

      // 사용자 정보 생성
      final now = DateTime.now();
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      // Firestore에 사용자 정보 저장
      await _saveUserToFirestore(userModel);

      return userModel.toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('FirebaseAuthService: 로그인 시도 - $email');

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('로그인에 실패했습니다');
      }

      debugPrint('FirebaseAuthService: Firebase 인증 성공, 마지막 로그인 시간 업데이트 중');

      // 마지막 로그인 시간 업데이트
      await _updateLastLoginTime(firebaseUser.uid);

      debugPrint('FirebaseAuthService: Firestore에서 사용자 정보 가져오기');

      // Firestore에서 사용자 정보 가져오기 (없으면 생성)
      final userModel = await _getOrCreateUserFromFirestore(firebaseUser);

      debugPrint('FirebaseAuthService: 로그인 완료 - ${userModel.email}');
      return userModel.toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthService: Firebase Auth 에러 - ${e.code}: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('FirebaseAuthService: 일반 에러 - $e');
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 구글 로그인 (향후 구현)
  Future<User> signInWithGoogle() async {
    throw UnimplementedError('구글 로그인은 아직 구현되지 않았습니다. 이메일/비밀번호 로그인을 사용해주세요.');
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('비밀번호 재설정 이메일 발송 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userModel = await _getOrCreateUserFromFirestore(firebaseUser);
      return userModel.toEntity();
    } catch (e) {
      debugPrint('사용자 정보 가져오기 실패: $e');
      return null;
    }
  }

  /// 사용자 정보 업데이트
  Future<User> updateUser(User user) async {
    try {
      final now = DateTime.now();
      final updatedUser = user.copyWith(updatedAt: now);
      final userModel = UserModel.fromEntity(updatedUser);

      // Firestore 업데이트 (merge 옵션으로 안전하게 처리)
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));

      return updatedUser;
    } catch (e) {
      throw Exception('사용자 정보 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 이미지 URL 업데이트
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다');

      await user.updatePhotoURL(imageUrl);

      // Firestore도 업데이트 (merge 옵션으로 안전하게 처리)
      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('프로필 이미지 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다');

      // Firestore에서 사용자 데이터 삭제
      await _firestore.collection('users').doc(user.uid).delete();

      // Firebase Authentication에서 계정 삭제
      await user.delete();
    } catch (e) {
      throw Exception('계정 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// Firestore에 사용자 정보 저장
  Future<void> _saveUserToFirestore(UserModel userModel) async {
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toFirestore());
  }

  /// Firestore에서 사용자 정보 가져오기
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('사용자 정보를 찾을 수 없습니다');
    }

    return UserModel.fromFirestore(doc.data()!);
  }

  /// Firestore에서 사용자 정보 가져오기 (없으면 생성)
  Future<UserModel> _getOrCreateUserFromFirestore(
      firebase_auth.User firebaseUser) async {
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      debugPrint('FirebaseAuthService: 사용자 문서가 없음, 새로 생성');

      // 사용자 문서가 없으면 새로 생성
      final now = DateTime.now();
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      // Firestore에 사용자 정보 저장
      await _saveUserToFirestore(userModel);
      return userModel;
    }

    return UserModel.fromFirestore(doc.data()!);
  }

  /// 마지막 로그인 시간 업데이트
  Future<void> _updateLastLoginTime(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'lastLoginAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Firebase Auth 예외 처리
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('비밀번호가 너무 약합니다. 6자 이상 입력해주세요');
      case 'email-already-in-use':
        return Exception('이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요');
      case 'user-not-found':
        return Exception('등록되지 않은 이메일입니다. 이메일을 확인하거나 회원가입을 해주세요');
      case 'wrong-password':
        return Exception('비밀번호가 일치하지 않습니다. 다시 확인해주세요');
      case 'invalid-email':
        return Exception('올바르지 않은 이메일 형식입니다');
      case 'user-disabled':
        return Exception('비활성화된 계정입니다. 고객센터에 문의해주세요');
      case 'too-many-requests':
        return Exception('로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요');
      case 'operation-not-allowed':
        return Exception('이 로그인 방법은 허용되지 않습니다');
      case 'invalid-credential':
        return Exception('이메일 또는 비밀번호가 올바르지 않습니다');
      case 'account-exists-with-different-credential':
        return Exception('이미 다른 로그인 방법으로 등록된 계정입니다');
      case 'network-request-failed':
        return Exception('네트워크 연결을 확인해주세요');
      default:
        return Exception('로그인 중 오류가 발생했습니다. 다시 시도해주세요');
    }
  }
}

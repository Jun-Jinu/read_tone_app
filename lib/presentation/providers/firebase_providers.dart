import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firebase_firestore_service.dart';
import '../../domain/entities/book.dart';

// Firebase 인증 서비스 프로바이더
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Firebase Firestore 서비스 프로바이더
final firebaseFirestoreServiceProvider =
    Provider<FirebaseFirestoreService>((ref) {
  return FirebaseFirestoreService();
});

// 현재 사용자 상태 프로바이더
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// 로그인 상태 프로바이더
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// 익명 사용자 확인 프로바이더
final isAnonymousProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.isAnonymous ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// 현재 사용자 정보 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Firebase 책 목록 프로바이더 (스트림)
final firebaseBooksProvider = StreamProvider<List<Book>>((ref) {
  final firestoreService = ref.read(firebaseFirestoreServiceProvider);
  final isLoggedIn = ref.watch(isLoggedInProvider);

  if (!isLoggedIn) {
    return Stream.value([]);
  }

  return firestoreService.getBooksStream();
});

// Firebase 책 관리 서비스 프로바이더
final firebaseBookServiceProvider = Provider<FirebaseBookService>((ref) {
  final firestoreService = ref.read(firebaseFirestoreServiceProvider);
  final authService = ref.read(firebaseAuthServiceProvider);
  return FirebaseBookService(firestoreService, authService, ref);
});

// Firebase 책 관리 서비스 클래스
class FirebaseBookService {
  final FirebaseFirestoreService _firestoreService;
  final FirebaseAuthService _authService;
  final ProviderRef _ref;

  FirebaseBookService(this._firestoreService, this._authService, this._ref);

  // 책 추가
  Future<String> addBook(Book book) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    return await _firestoreService.addBook(book);
  }

  // 책 수정
  Future<void> updateBook(Book book) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.updateBook(book);
  }

  // 책 삭제
  Future<void> deleteBook(String bookId) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.deleteBook(bookId);
  }

  // 읽기 진행률 업데이트
  Future<void> updateReadingProgress(String bookId, int currentPage) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.updateReadingProgress(bookId, currentPage);
  }

  // 책 완독 처리
  Future<void> completeBook(String bookId) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.completeBook(bookId);
  }

  // 로컬 데이터와 동기화
  Future<void> syncWithLocalData(List<Book> localBooks) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.syncWithLocalData(localBooks);
  }

  // 데이터 백업
  Future<Map<String, dynamic>> backupUserData() async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    return await _firestoreService.backupUserData();
  }

  // 데이터 복원
  Future<void> restoreUserData(Map<String, dynamic> backupData) async {
    if (!_authService.isLoggedIn) {
      throw Exception('로그인이 필요합니다.');
    }
    await _firestoreService.restoreUserData(backupData);
  }
}

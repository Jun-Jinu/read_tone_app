import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_note.dart';
import '../models/book_model.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 ID 가져오기
  String? get _currentUserId => _auth.currentUser?.uid;

  // 사용자별 책 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _booksCollection {
    if (_currentUserId == null) {
      throw Exception('로그인이 필요합니다.');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('books');
  }

  // 모든 책 조회
  Future<List<Book>> getAllBooks() async {
    try {
      final snapshot = await _booksCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookModel.fromFirestore(data).toEntity();
      }).toList();
    } catch (e) {
      throw Exception('책 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 책 조회 (스트림)
  Stream<List<Book>> getBooksStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _booksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return BookModel.fromFirestore(data).toEntity();
          }).toList();
        });
  }

  // 특정 책 조회
  Future<Book?> getBookById(String bookId) async {
    try {
      final doc = await _booksCollection.doc(bookId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return BookModel.fromFirestore(data).toEntity();
    } catch (e) {
      throw Exception('책 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 책 추가
  Future<String> addBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final docRef = await _booksCollection.add({
        ...bookModel.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('책 추가에 실패했습니다: $e');
    }
  }

  // 책 수정
  Future<void> updateBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await _booksCollection.doc(book.id).update({
        ...bookModel.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('책 수정에 실패했습니다: $e');
    }
  }

  // 책 삭제
  Future<void> deleteBook(String bookId) async {
    try {
      await _booksCollection.doc(bookId).delete();
    } catch (e) {
      throw Exception('책 삭제에 실패했습니다: $e');
    }
  }

  // 읽기 진행률 업데이트
  Future<void> updateReadingProgress(String bookId, int currentPage) async {
    try {
      await _booksCollection.doc(bookId).update({
        'currentPage': currentPage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('읽기 진행률 업데이트에 실패했습니다: $e');
    }
  }

  // 책 완독 처리
  Future<void> completeBook(String bookId) async {
    try {
      await _booksCollection.doc(bookId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('책 완독 처리에 실패했습니다: $e');
    }
  }

  // 독서 노트 추가
  Future<void> addReadingNote(String bookId, ReadingNote note) async {
    try {
      final book = await getBookById(bookId);
      if (book == null) throw Exception('책을 찾을 수 없습니다.');

      final updatedNotes = [...book.notes, note];
      await _booksCollection.doc(bookId).update({
        'notes': updatedNotes
            .map(
              (n) => {
                'id': n.id,
                'title': n.title,
                'content': n.content,
                'pageNumber': n.pageNumber,
                'createdAt': n.createdAt.toIso8601String(),
                'updatedAt': n.updatedAt.toIso8601String(),
              },
            )
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('독서 노트 추가에 실패했습니다: $e');
    }
  }

  // 독서 노트 수정
  Future<void> updateReadingNote(String bookId, ReadingNote note) async {
    try {
      final book = await getBookById(bookId);
      if (book == null) throw Exception('책을 찾을 수 없습니다.');

      final updatedNotes = book.notes
          .map((n) => n.id == note.id ? note : n)
          .toList();
      await _booksCollection.doc(bookId).update({
        'notes': updatedNotes
            .map(
              (n) => {
                'id': n.id,
                'title': n.title,
                'content': n.content,
                'pageNumber': n.pageNumber,
                'createdAt': n.createdAt.toIso8601String(),
                'updatedAt': n.updatedAt.toIso8601String(),
              },
            )
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('독서 노트 수정에 실패했습니다: $e');
    }
  }

  // 독서 노트 삭제
  Future<void> deleteReadingNote(String bookId, String noteId) async {
    try {
      final book = await getBookById(bookId);
      if (book == null) throw Exception('책을 찾을 수 없습니다.');

      final updatedNotes = book.notes.where((n) => n.id != noteId).toList();
      await _booksCollection.doc(bookId).update({
        'notes': updatedNotes
            .map(
              (n) => {
                'id': n.id,
                'title': n.title,
                'content': n.content,
                'pageNumber': n.pageNumber,
                'createdAt': n.createdAt.toIso8601String(),
                'updatedAt': n.updatedAt.toIso8601String(),
              },
            )
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('독서 노트 삭제에 실패했습니다: $e');
    }
  }

  // 사용자 데이터 백업
  Future<Map<String, dynamic>> backupUserData() async {
    try {
      final books = await getAllBooks();
      return {
        'userId': _currentUserId,
        'exportedAt': DateTime.now().toIso8601String(),
        'books': books
            .map((book) => BookModel.fromEntity(book).toFirestore())
            .toList(),
      };
    } catch (e) {
      throw Exception('데이터 백업에 실패했습니다: $e');
    }
  }

  // 사용자 데이터 복원
  Future<void> restoreUserData(Map<String, dynamic> backupData) async {
    try {
      final List<dynamic> booksData = backupData['books'] ?? [];

      // 배치 작업으로 처리
      final batch = _firestore.batch();

      for (final bookData in booksData) {
        final docRef = _booksCollection.doc();
        batch.set(docRef, {
          ...bookData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('데이터 복원에 실패했습니다: $e');
    }
  }

  // 로컬 데이터와 동기화
  Future<void> syncWithLocalData(List<Book> localBooks) async {
    try {
      final batch = _firestore.batch();

      for (final book in localBooks) {
        final bookModel = BookModel.fromEntity(book);
        final docRef = _booksCollection.doc(book.id.isEmpty ? null : book.id);

        batch.set(docRef, {
          ...bookModel.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('데이터 동기화에 실패했습니다: $e');
    }
  }

  // 오프라인 지원을 위한 캐시 설정
  Future<void> enableOfflineSupport() async {
    try {
      await _firestore.enableNetwork();
      // await _firestore.enablePersistence();
    } catch (e) {
      // 이미 활성화되어 있거나 지원하지 않는 플랫폼
      print('오프라인 지원 활성화 실패: $e');
    }
  }
}

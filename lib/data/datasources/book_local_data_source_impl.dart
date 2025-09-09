import 'package:read_tone_app/core/utils/database_service.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source.dart';
import 'package:read_tone_app/data/models/book_model.dart';
import '../../domain/entities/book.dart';

class BookLocalDataSourceImpl implements BookLocalDataSource {
  @override
  Future<List<Book>> getLastBooks() async {
    final db = await DatabaseService.database;

    // 책 데이터 조회 (새로운 필드들 포함)
    final booksData = await db.query('books');

    // 결과를 Book 엔티티 리스트로 변환
    return booksData.map((map) => BookModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<void> cacheBooks(List<Book> books) async {
    final db = await DatabaseService.database;

    // 트랜잭션 시작
    await db.transaction((txn) async {
      for (final book in books) {
        final bookModel = BookModel.fromEntity(book);

        // 기존 책이 있는지 확인
        final existingBook = await txn.query(
          'books',
          where: 'bookId = ?',
          whereArgs: [bookModel.bookId],
          limit: 1,
        );

        if (existingBook.isNotEmpty) {
          // 업데이트 (새로운 필드들 포함)
          await txn.update(
            'books',
            bookModel.toMap(),
            where: 'bookId = ?',
            whereArgs: [bookModel.bookId],
          );
        } else {
          // 삽입 (새로운 필드들 포함)
          await txn.insert('books', bookModel.toMap());
        }
      }
    });
  }

  @override
  Future<void> cacheBook(Book book) async {
    final db = await DatabaseService.database;
    final bookModel = BookModel.fromEntity(book);

    // 기존 책이 있는지 확인
    final existingBook = await db.query(
      'books',
      where: 'bookId = ?',
      whereArgs: [bookModel.bookId],
      limit: 1,
    );

    if (existingBook.isNotEmpty) {
      // 업데이트 (새로운 필드들 포함)
      await db.update(
        'books',
        bookModel.toMap(),
        where: 'bookId = ?',
        whereArgs: [bookModel.bookId],
      );
    } else {
      // 삽입 (새로운 필드들 포함)
      await db.insert('books', bookModel.toMap());
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    final db = await DatabaseService.database;

    // 책 삭제 (연관된 세션들도 CASCADE로 자동 삭제됨)
    await db.delete(
      'books',
      where: 'bookId = ?',
      whereArgs: [id],
    );
  }

  // 효율적인 조회를 위한 추가 메서드들
  Future<List<Book>> getRecentBooks({
    int limit = 20,
    String? status,
  }) async {
    final booksData = await DatabaseService.getRecentBooks(
      limit: limit,
      status: status,
    );
    return booksData.map((data) => BookModel.fromMap(data).toEntity()).toList();
  }

  Future<List<Book>> getFavoriteBooks({
    String? status,
    int limit = 20,
  }) async {
    final db = await DatabaseService.database;
    String query = '''
      SELECT * FROM books 
      WHERE isFavorite = 1
    ''';

    List<dynamic> args = [];
    if (status != null) {
      query += ' AND status = ?';
      args.add(status);
    }

    // SQLite에서는 NULL 값들이 기본적으로 작은 값으로 취급됨
    // DESC NULLS LAST 효과를 얻기 위해 COALESCE 사용
    query +=
        ' ORDER BY COALESCE(lastReadAt, updatedAt) DESC, updatedAt DESC LIMIT ?';
    args.add(limit);

    final result = await db.rawQuery(query, args);
    return result.map((data) => BookModel.fromMap(data).toEntity()).toList();
  }

  Future<List<Book>> getHighPriorityBooks({
    String? status,
    int limit = 20,
  }) async {
    final db = await DatabaseService.database;
    String query = '''
      SELECT * FROM books 
      WHERE (isFavorite = 1 OR priority > 0)
    ''';

    List<dynamic> args = [];
    if (status != null) {
      query += ' AND status = ?';
      args.add(status);
    }

    query += '''
      ORDER BY isFavorite DESC, priority DESC, 
               COALESCE(lastReadAt, updatedAt) DESC, updatedAt DESC 
      LIMIT ?
    ''';
    args.add(limit);

    final result = await db.rawQuery(query, args);
    return result.map((data) => BookModel.fromMap(data).toEntity()).toList();
  }

  // 책 상태 및 활동 업데이트
  Future<void> updateBookStatus(String bookId, String status) async {
    await DatabaseService.updateBookStatus(bookId, status);
  }

  Future<void> updateBookActivity(String bookId) async {
    await DatabaseService.updateBookActivity(bookId);
  }

  Future<void> toggleBookFavorite(String bookId) async {
    final db = await DatabaseService.database;

    // 현재 즐겨찾기 상태 확인
    final result = await db.query(
      'books',
      columns: ['isFavorite'],
      where: 'bookId = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final currentFavorite = result.first['isFavorite'] as int;
      final newFavorite = currentFavorite == 1 ? 0 : 1;

      await db.update(
        'books',
        {
          'isFavorite': newFavorite,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    }
  }

  Future<void> updateBookPriority(String bookId, int priority) async {
    final db = await DatabaseService.database;
    await db.update(
      'books',
      {
        'priority': priority,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }
}

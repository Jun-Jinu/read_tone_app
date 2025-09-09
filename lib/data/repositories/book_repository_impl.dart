import 'package:dartz/dartz.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/core/utils/database_service.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source.dart';
import 'package:read_tone_app/data/datasources/book_remote_data_source.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final books = await remoteDataSource.getBooks();
      await localDataSource.cacheBooks(books);
      return Right(books);
    } catch (e) {
      final cachedBooks = await localDataSource.getLastBooks();
      if (cachedBooks.isNotEmpty) {
        return Right(cachedBooks);
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBook(String id) async {
    try {
      final book = await remoteDataSource.getBook(id);
      await localDataSource.cacheBook(book);
      return Right(book);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> addBook(Book book) async {
    try {
      final newBook = await remoteDataSource.addBook(book);
      await localDataSource.cacheBook(newBook);
      return Right(newBook);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(Book book) async {
    try {
      await remoteDataSource.updateBook(book);
      await localDataSource.cacheBook(book);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String id) async {
    try {
      await remoteDataSource.deleteBook(id);
      await localDataSource.deleteBook(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    try {
      final books = await remoteDataSource.searchBooks(query);
      return Right(books);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // 효율적인 최근 책 조회 메서드들
  @override
  Future<Either<Failure, List<Book>>> getRecentBooks({int limit = 20}) async {
    try {
      final booksData = await DatabaseService.getRecentBooks(limit: limit);
      final books = booksData.map((data) => _mapToBook(data)).toList();
      return Right(books);
    } catch (e) {
      return Left(CacheFailure(message: '최근 책 조회 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getRecentBooksByStatus({
    required BookStatus status,
    int limit = 20,
  }) async {
    try {
      final statusString = status.toString().split('.').last;
      final booksData = await DatabaseService.getRecentBooks(
        limit: limit,
        status: statusString,
      );
      final books = booksData.map((data) => _mapToBook(data)).toList();
      return Right(books);
    } catch (e) {
      return Left(CacheFailure(message: '상태별 책 조회 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getFavoriteBooks({
    BookStatus? status,
    int limit = 20,
  }) async {
    try {
      final db = await DatabaseService.database;
      String query = '''
        SELECT * FROM books 
        WHERE isFavorite = 1
      ''';

      List<dynamic> args = [];
      if (status != null) {
        query += ' AND status = ?';
        args.add(status.toString().split('.').last);
      }

      query +=
          ' ORDER BY COALESCE(lastReadAt, updatedAt) DESC, updatedAt DESC LIMIT ?';
      args.add(limit);

      final result = await db.rawQuery(query, args);
      final books = result.map((data) => _mapToBook(data)).toList();
      return Right(books);
    } catch (e) {
      return Left(CacheFailure(message: '즐겨찾기 책 조회 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getHighPriorityBooks({
    BookStatus? status,
    int limit = 20,
  }) async {
    try {
      final db = await DatabaseService.database;
      String query = '''
        SELECT * FROM books 
        WHERE (isFavorite = 1 OR priority > 0)
      ''';

      List<dynamic> args = [];
      if (status != null) {
        query += ' AND status = ?';
        args.add(status.toString().split('.').last);
      }

      query += '''
        ORDER BY isFavorite DESC, priority DESC,
                 COALESCE(lastReadAt, updatedAt) DESC, updatedAt DESC 
        LIMIT ?
      ''';
      args.add(limit);

      final result = await db.rawQuery(query, args);
      final books = result.map((data) => _mapToBook(data)).toList();
      return Right(books);
    } catch (e) {
      return Left(CacheFailure(message: '우선순위 책 조회 실패: ${e.toString()}'));
    }
  }

  // 책 상태 및 활동 업데이트
  @override
  Future<Either<Failure, void>> updateBookStatus(
    String bookId,
    BookStatus status,
  ) async {
    try {
      final statusString = status.toString().split('.').last;
      await DatabaseService.updateBookStatus(bookId, statusString);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: '책 상태 업데이트 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookActivity(String bookId) async {
    try {
      await DatabaseService.updateBookActivity(bookId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: '책 활동 업데이트 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBookFavorite(String bookId) async {
    try {
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

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: '즐겨찾기 토글 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookPriority(
    String bookId,
    int priority,
  ) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        'books',
        {'priority': priority, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: '우선순위 업데이트 실패: ${e.toString()}'));
    }
  }

  // 통계 조회
  @override
  Future<Either<Failure, Map<String, int>>> getBookCountsByStatus() async {
    try {
      final counts = await DatabaseService.getBookCountsByStatus();
      return Right(counts);
    } catch (e) {
      return Left(CacheFailure(message: '상태별 책 수 조회 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReadingStats(
    int year,
  ) async {
    try {
      final stats = await DatabaseService.getMonthlyReadingStats(year);
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure(message: '월별 독서 통계 조회 실패: ${e.toString()}'));
    }
  }

  // 데이터베이스 Map을 Book 엔티티로 변환하는 헬퍼 메서드
  Book _mapToBook(Map<String, dynamic> data) {
    return Book(
      id: data['bookId'] as String,
      title: data['title'] as String,
      author: data['author'] as String,
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      totalPages: data['totalPages'] as int? ?? 0,
      currentPage: data['currentPage'] as int? ?? 0,
      status: _parseBookStatus(data['status'] as String),
      createdAt: DateTime.parse(
        data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      startedAt: data['startedAt'] != null
          ? DateTime.parse(data['startedAt'] as String)
          : null,
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      updatedAt: DateTime.parse(
        data['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastReadAt: data['lastReadAt'] != null
          ? DateTime.parse(data['lastReadAt'] as String)
          : null,
      readingSessions: [], // 필요시 별도 쿼리로 로드
      memo: data['memo'] as String?,
      notes: [], // 필요시 별도 쿼리로 로드
      themeColor: null, // Color 파싱 로직 필요시 추가
      priority: data['priority'] as int? ?? 0,
      isFavorite: (data['isFavorite'] as int? ?? 0) == 1,
    );
  }

  BookStatus _parseBookStatus(String status) {
    switch (status) {
      case 'reading':
        return BookStatus.reading;
      case 'completed':
        return BookStatus.completed;
      case 'paused':
        return BookStatus.paused;
      case 'planned':
      default:
        return BookStatus.planned;
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book>> getBook(String id);
  Future<Either<Failure, Book>> addBook(Book book);
  Future<Either<Failure, void>> updateBook(Book book);
  Future<Either<Failure, void>> deleteBook(String id);
  Future<Either<Failure, List<Book>>> searchBooks(String query);

  // 효율적인 최근 책 조회 메서드들
  Future<Either<Failure, List<Book>>> getRecentBooks({int limit = 20});
  Future<Either<Failure, List<Book>>> getRecentBooksByStatus({
    required BookStatus status,
    int limit = 20,
  });
  Future<Either<Failure, List<Book>>> getFavoriteBooks({
    BookStatus? status,
    int limit = 20,
  });
  Future<Either<Failure, List<Book>>> getHighPriorityBooks({
    BookStatus? status,
    int limit = 20,
  });

  // 책 상태 및 활동 업데이트
  Future<Either<Failure, void>> updateBookStatus(
      String bookId, BookStatus status);
  Future<Either<Failure, void>> updateBookActivity(String bookId);
  Future<Either<Failure, void>> toggleBookFavorite(String bookId);
  Future<Either<Failure, void>> updateBookPriority(String bookId, int priority);

  // 통계 조회
  Future<Either<Failure, Map<String, int>>> getBookCountsByStatus();
  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReadingStats(
      int year);
}

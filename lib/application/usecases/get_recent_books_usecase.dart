import 'package:dartz/dartz.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../core/error/failures.dart';

class GetRecentBooksUseCase {
  final BookRepository repository;

  GetRecentBooksUseCase(this.repository);

  // 모든 최근 책들 조회
  Future<Either<Failure, List<Book>>> call({
    int limit = 20,
  }) async {
    return await repository.getRecentBooks(limit: limit);
  }

  // 특정 상태의 최근 책들 조회
  Future<Either<Failure, List<Book>>> getByStatus({
    required BookStatus status,
    int limit = 20,
  }) async {
    return await repository.getRecentBooksByStatus(
      status: status,
      limit: limit,
    );
  }

  // 즐겨찾기 책들 조회
  Future<Either<Failure, List<Book>>> getFavoriteBooks({
    BookStatus? status,
    int limit = 20,
  }) async {
    return await repository.getFavoriteBooks(
      status: status,
      limit: limit,
    );
  }

  // 우선순위가 높은 책들 조회
  Future<Either<Failure, List<Book>>> getHighPriorityBooks({
    BookStatus? status,
    int limit = 20,
  }) async {
    return await repository.getHighPriorityBooks(
      status: status,
      limit: limit,
    );
  }

  // 현재 읽고 있는 책들 조회 (최근 활동 순)
  Future<Either<Failure, List<Book>>> getCurrentlyReading({
    int limit = 10,
  }) async {
    return await getByStatus(status: BookStatus.reading, limit: limit);
  }

  // 읽을 예정인 책들 조회 (우선순위/생성일 순)
  Future<Either<Failure, List<Book>>> getPlannedBooks({
    int limit = 20,
  }) async {
    return await getByStatus(status: BookStatus.planned, limit: limit);
  }

  // 완료된 책들 조회 (완료일 순)
  Future<Either<Failure, List<Book>>> getCompletedBooks({
    int limit = 20,
  }) async {
    return await getByStatus(status: BookStatus.completed, limit: limit);
  }
}

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';

abstract class BookSearchRepository {
  /// 외부 API에서 도서 검색
  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    String sort = 'accuracy',
    int page = 1,
    int size = 10,
  });
}

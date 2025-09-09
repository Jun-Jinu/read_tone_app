import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_search_repository.dart';
import '../datasources/kakao_book_api_service.dart';
import '../datasources/aladin_book_api_service.dart';
import '../models/aladin_book_model.dart';

class BookSearchRepositoryImpl implements BookSearchRepository {
  final KakaoBookApiService _kakao;
  final AladinBookApiService _aladin;

  BookSearchRepositoryImpl({required KakaoBookApiService apiService})
    : _kakao = apiService,
      _aladin = AladinBookApiService();

  @override
  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    String sort = 'accuracy',
    int page = 1,
    int size = 10,
  }) async {
    try {
      // 1순위: 알라딘 검색 (페이지 수 포함)
      try {
        final aladin = await _aladin.searchBooks(
          query: query,
          sort: _mapSortForAladin(sort),
          page: page,
          size: size,
        );
        final books = aladin.items.map((AladinItem e) => e.toEntity()).toList();
        if (books.isNotEmpty) {
          return Right(books);
        }
      } catch (_) {
        // 알라딘 실패 시 카카오로 폴백
      }

      final kakao = await _kakao.searchBooks(
        query: query,
        sort: sort,
        page: page,
        size: size,
      );
      final books = kakao.documents
          .map((kakaoBook) => kakaoBook.toBookEntity())
          .toList();

      return Right(books);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _mapSortForAladin(String kakaoSort) {
    switch (kakaoSort) {
      case 'recency':
        return 'PublishTime';
      default:
        return 'Accuracy';
    }
  }
}

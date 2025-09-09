import 'package:read_tone_app/data/datasources/book_remote_data_source.dart';
import 'package:read_tone_app/data/models/book_model.dart';
import '../../domain/entities/book.dart';
import 'package:dio/dio.dart';

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  // 임시 Mock 데이터 (추후 실제 API로 교체)
  final List<BookModel> _mockBooks = [];
  final Dio _dio = Dio();

  @override
  Future<List<Book>> getBooks() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500)); // API 지연 시뮬레이션

    // Mock 데이터 반환
    return _mockBooks.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Book> getBook(String id) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 300));

    final bookModel = _mockBooks.firstWhere(
      (book) => book.bookId == id,
      orElse: () => throw Exception('Book not found'),
    );

    return bookModel.toEntity();
  }

  @override
  Future<Book> addBook(Book book) async {
    try {
      // Book 엔티티를 BookModel로 변환
      final bookModel = BookModel.fromEntity(book);

      // API 요청 (실제 구현 시 실제 API 엔드포인트 사용)
      final response = await _dio.post(
        '/books',
        data: bookModel.toJson(),
      );

      // 응답에서 ID를 받아서 업데이트된 Book 객체 반환
      final updatedBook = book.copyWith(id: response.data['id'] as String);
      return updatedBook;
    } catch (e) {
      throw Exception('책 추가에 실패했습니다: $e');
    }
  }

  @override
  Future<void> updateBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);

      await _dio.put(
        '/books/${book.id}',
        data: bookModel.toJson(),
      );
    } catch (e) {
      throw Exception('책 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockBooks.indexWhere((book) => book.bookId == id);
    if (index != -1) {
      _mockBooks.removeAt(index);
    } else {
      throw Exception('Book not found');
    }
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 600));

    final filteredBooks = _mockBooks
        .where((book) =>
            book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.author.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredBooks.map((model) => model.toEntity()).toList();
  }

  // 추가 메서드들 (향후 API 확장시 사용)

  /// 서버 동기화를 위한 메서드
  Future<List<Book>> syncBooks(List<Book> localBooks) async {
    // TODO: 서버와 로컬 데이터 동기화 로직 구현
    await Future.delayed(const Duration(milliseconds: 1000));

    // 임시로 로컬 데이터 반환
    return localBooks;
  }

  /// 사용자별 책 목록 조회
  Future<List<Book>> getUserBooks(String userId) async {
    // TODO: 사용자별 책 목록 API 호출
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockBooks.map((model) => model.toEntity()).toList();
  }

  /// 책 상태 업데이트 (서버)
  Future<void> updateBookStatus(String bookId, String status) async {
    // TODO: 책 상태 업데이트 API 호출
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockBooks.indexWhere((book) => book.bookId == bookId);
    if (index != -1) {
      _mockBooks[index] = _mockBooks[index].copyWith(
        status: status,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  /// 즐겨찾기 토글 (서버)
  Future<void> toggleBookFavorite(String bookId) async {
    // TODO: 즐겨찾기 토글 API 호출
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockBooks.indexWhere((book) => book.bookId == bookId);
    if (index != -1) {
      final currentFavorite = _mockBooks[index].isFavorite;
      _mockBooks[index] = _mockBooks[index].copyWith(
        isFavorite: currentFavorite == 1 ? 0 : 1,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  /// 우선순위 업데이트 (서버)
  Future<void> updateBookPriority(String bookId, int priority) async {
    // TODO: 우선순위 업데이트 API 호출
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockBooks.indexWhere((book) => book.bookId == bookId);
    if (index != -1) {
      _mockBooks[index] = _mockBooks[index].copyWith(
        priority: priority,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  /// 외부 책 검색 (예: Google Books API)
  Future<List<Book>> searchExternalBooks(String query) async {
    // TODO: 외부 API (Google Books 등)에서 책 검색
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock 검색 결과 반환
    return [
      BookModel(
        bookId: 'ext_${DateTime.now().millisecondsSinceEpoch}',
        title: '검색된 책: $query',
        author: '외부 작가',
        totalPages: 250,
        currentPage: 0,
        status: 'planned',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        priority: 0,
        isFavorite: 0,
        coverImageUrl: 'https://example.com/cover.jpg',
        description: '외부 API에서 검색된 책입니다.',
      ).toEntity(),
    ];
  }
}

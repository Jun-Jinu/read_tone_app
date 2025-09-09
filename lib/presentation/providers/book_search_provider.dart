import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/kakao_book_api_service.dart';
import '../../data/datasources/aladin_book_api_service.dart';
import '../../data/repositories/book_search_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_search_repository.dart';

// 카카오 API 서비스 Provider
final kakaoBookApiServiceProvider = Provider<KakaoBookApiService>((ref) {
  return KakaoBookApiService();
});

// 알라딘 API 서비스 Provider
final aladinBookApiServiceProvider = Provider<AladinBookApiService>((ref) {
  return AladinBookApiService();
});

// 도서 검색 Repository Provider
final bookSearchRepositoryProvider = Provider<BookSearchRepository>((ref) {
  final apiService = ref.watch(kakaoBookApiServiceProvider);
  return BookSearchRepositoryImpl(apiService: apiService);
});

// 도서 검색 상태 관리
class BookSearchState {
  final List<Book> books;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const BookSearchState({
    this.books = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  BookSearchState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return BookSearchState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// 도서 검색 StateNotifier
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  final BookSearchRepository _repository;
  String _currentQuery = '';

  BookSearchNotifier(this._repository) : super(const BookSearchState());

  /// 새로운 검색 시작
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) return;

    _currentQuery = query.trim();
    state = const BookSearchState(isLoading: true);

    final result = await _repository.searchBooks(
      query: _currentQuery,
      page: 1,
      size: 10,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (books) => state = state.copyWith(
        isLoading: false,
        books: books,
        hasMore: books.length >= 10,
        currentPage: 1,
        error: null,
      ),
    );
  }

  /// 더 많은 결과 로드 (페이지네이션)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || _currentQuery.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final result = await _repository.searchBooks(
      query: _currentQuery,
      page: state.currentPage + 1,
      size: 10,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (newBooks) => state = state.copyWith(
        isLoading: false,
        books: [...state.books, ...newBooks],
        hasMore: newBooks.length >= 10,
        currentPage: state.currentPage + 1,
        error: null,
      ),
    );
  }

  /// 검색 결과 초기화
  void clearSearch() {
    state = const BookSearchState();
    _currentQuery = '';
  }
}

// 도서 검색 Provider
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>((ref) {
      final repository = ref.watch(bookSearchRepositoryProvider);
      return BookSearchNotifier(repository);
    });

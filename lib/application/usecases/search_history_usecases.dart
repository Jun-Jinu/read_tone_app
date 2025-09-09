import 'package:read_tone_app/domain/entities/search_history.dart';
import 'package:read_tone_app/domain/repositories/search_history_repository.dart';

/// 검색 기록 추가 유스케이스
class AddSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  AddSearchHistoryUseCase(this._repository);

  Future<void> call(String query) async {
    // 동일한 검색어가 이미 존재하는지 확인
    final searchResults = await _repository.searchHistoryByQuery(query);

    if (searchResults.isNotEmpty) {
      // 이미 존재하는 검색어라면 생성 시간만 업데이트
      final existingHistory = searchResults.first;
      final updatedHistory = existingHistory.copyWith(
        createdAt: DateTime.now(),
      );
      return _repository.updateSearchHistory(updatedHistory);
    } else {
      // 새 검색어라면 추가
      final newHistory = SearchHistory.create(query);
      return _repository.addSearchHistory(newHistory);
    }
  }
}

/// 최근 검색 기록 가져오기 유스케이스
class GetRecentSearchHistoryUseCase {
  final SearchHistoryRepository _repository;
  final int defaultLimit;

  GetRecentSearchHistoryUseCase(this._repository, {this.defaultLimit = 10});

  Future<List<SearchHistory>> call({int? limit}) {
    return _repository.getRecentSearchHistory(limit ?? defaultLimit);
  }
}

/// 즐겨찾기 검색 기록 가져오기 유스케이스
class GetFavoriteSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  GetFavoriteSearchHistoryUseCase(this._repository);

  Future<List<SearchHistory>> call() {
    return _repository.getFavoriteSearchHistory();
  }
}

/// 검색 기록 삭제 유스케이스
class DeleteSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  DeleteSearchHistoryUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteSearchHistory(id);
  }
}

/// 모든 검색 기록 삭제 유스케이스
class ClearSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  ClearSearchHistoryUseCase(this._repository);

  Future<void> call() {
    return _repository.deleteAllSearchHistory();
  }
}

/// 검색 기록 즐겨찾기 토글 유스케이스
class ToggleFavoriteSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  ToggleFavoriteSearchHistoryUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.toggleFavorite(id);
  }
}

/// 검색 기록 관찰 유스케이스
class ObserveSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  ObserveSearchHistoryUseCase(this._repository);

  Stream<List<SearchHistory>> call() {
    return _repository.observeSearchHistory();
  }
}

/// 검색어로 검색 기록 조회 유스케이스
class SearchHistoryByQueryUseCase {
  final SearchHistoryRepository _repository;

  SearchHistoryByQueryUseCase(this._repository);

  Future<List<SearchHistory>> call(String query) {
    return _repository.searchHistoryByQuery(query);
  }
}

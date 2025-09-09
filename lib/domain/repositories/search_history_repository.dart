import 'package:read_tone_app/domain/entities/search_history.dart';

abstract class SearchHistoryRepository {
  /// 모든 검색 기록 가져오기
  Future<List<SearchHistory>> getAllSearchHistory();

  /// 최근 검색 기록 가져오기 (개수 제한)
  Future<List<SearchHistory>> getRecentSearchHistory(int limit);

  /// 즐겨찾기한 검색 기록 가져오기
  Future<List<SearchHistory>> getFavoriteSearchHistory();

  /// 검색 기록 추가하기
  Future<void> addSearchHistory(SearchHistory searchHistory);

  /// 검색 기록 업데이트하기
  Future<void> updateSearchHistory(SearchHistory searchHistory);

  /// 검색 기록 삭제하기
  Future<void> deleteSearchHistory(String id);

  /// 모든 검색 기록 삭제하기
  Future<void> deleteAllSearchHistory();

  /// 즐겨찾기 토글하기
  Future<void> toggleFavorite(String id);

  /// 검색 기록 스트림 관찰하기
  Stream<List<SearchHistory>> observeSearchHistory();

  /// 검색어로 검색 기록 조회하기
  Future<List<SearchHistory>> searchHistoryByQuery(String query);
}

class SearchHistory {
  final String id;
  final String query;
  final DateTime createdAt;
  final bool isFavorite;

  const SearchHistory({
    required this.id,
    required this.query,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// 복사본 생성 메서드
  SearchHistory copyWith({
    String? id,
    String? query,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return SearchHistory(
      id: id ?? this.id,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// ID없이 검색어와 현재 시간으로 새 검색 기록 생성
  factory SearchHistory.create(String query) {
    return SearchHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      createdAt: DateTime.now(),
    );
  }

  /// 즐겨찾기 여부 토글
  SearchHistory toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }
}

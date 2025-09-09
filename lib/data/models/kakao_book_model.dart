import '../../domain/entities/book.dart';

class KakaoBookSearchResponse {
  final KakaoBookMeta meta;
  final List<KakaoBookModel> documents;

  const KakaoBookSearchResponse({
    required this.meta,
    required this.documents,
  });

  factory KakaoBookSearchResponse.fromJson(Map<String, dynamic> json) {
    return KakaoBookSearchResponse(
      meta: KakaoBookMeta.fromJson(json['meta'] ?? {}),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => KakaoBookModel.fromJson(doc))
          .toList(),
    );
  }
}

class KakaoBookMeta {
  final int totalCount;
  final int pageableCount;
  final bool isEnd;

  const KakaoBookMeta({
    required this.totalCount,
    required this.pageableCount,
    required this.isEnd,
  });

  factory KakaoBookMeta.fromJson(Map<String, dynamic> json) {
    return KakaoBookMeta(
      totalCount: json['total_count'] ?? 0,
      pageableCount: json['pageable_count'] ?? 0,
      isEnd: json['is_end'] ?? true,
    );
  }
}

class KakaoBookModel {
  final String title;
  final String contents;
  final String url;
  final String isbn;
  final String datetime;
  final List<String> authors;
  final String publisher;
  final List<String> translators;
  final int price;
  final int salePrice;
  final String thumbnail;
  final String status;

  const KakaoBookModel({
    required this.title,
    required this.contents,
    required this.url,
    required this.isbn,
    required this.datetime,
    required this.authors,
    required this.publisher,
    required this.translators,
    required this.price,
    required this.salePrice,
    required this.thumbnail,
    required this.status,
  });

  factory KakaoBookModel.fromJson(Map<String, dynamic> json) {
    return KakaoBookModel(
      title: json['title'] ?? '',
      contents: json['contents'] ?? '',
      url: json['url'] ?? '',
      isbn: json['isbn'] ?? '',
      datetime: json['datetime'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      publisher: json['publisher'] ?? '',
      translators: List<String>.from(json['translators'] ?? []),
      price: json['price'] ?? 0,
      salePrice: json['sale_price'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Domain Entity로 변환
  Book toBookEntity() {
    // ISBN에서 페이지 수를 추정 (실제로는 별도 API나 로직 필요)
    final estimatedPages = _estimatePages();

    return Book(
      id: isbn.isNotEmpty
          ? isbn
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: authors.isNotEmpty ? authors.join(', ') : '알 수 없는 저자',
      coverImageUrl: thumbnail,
      totalPages: estimatedPages,
      currentPage: 0,
      status: BookStatus.planned,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      readingSessions: [],
      notes: [],
      priority: 0,
      isFavorite: false,
    );
  }

  // 페이지 수 추정 로직 (간단한 휴리스틱)
  int _estimatePages() {
    // 기본값: 200페이지
    // 실제로는 다른 API나 데이터베이스에서 가져와야 함
    return 200;
  }

  // 검색 결과 표시용 요약 정보
  String get displayAuthors =>
      authors.isNotEmpty ? authors.join(', ') : '알 수 없는 저자';
  String get displayPrice => price > 0
      ? '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
      : '가격 정보 없음';
  String get shortContents =>
      contents.length > 100 ? '${contents.substring(0, 100)}...' : contents;
}

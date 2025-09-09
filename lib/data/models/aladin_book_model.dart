import '../../domain/entities/book.dart';

class AladinBookSearchResponse {
  final List<AladinItem> items;

  const AladinBookSearchResponse({required this.items});

  factory AladinBookSearchResponse.fromJson(Map<String, dynamic> json) {
    final itemList = (json['item'] as List<dynamic>? ?? [])
        .map((e) => AladinItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AladinBookSearchResponse(items: itemList);
  }
}

class AladinItem {
  final String title;
  final String author;
  final String publisher;
  final String isbn13;
  final String cover;
  final int? pageCount;
  final String? description;

  const AladinItem({
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn13,
    required this.cover,
    required this.pageCount,
    this.description,
  });

  factory AladinItem.fromJson(Map<String, dynamic> json) {
    int? pages;
    // subInfo.itemPage 우선
    final subInfo = json['subInfo'];
    if (subInfo is Map<String, dynamic>) {
      pages = _parseInt(subInfo['itemPage']);
    }
    // 루트에 itemPage가 오는 경우 처리
    pages ??= _parseInt(json['itemPage']);

    String? desc;
    if (subInfo is Map<String, dynamic>) {
      // 알라딘은 description / fullDescription 등으로 노출될 수 있음
      desc = (subInfo['fullDescription'] ?? subInfo['description'])?.toString();
    }
    desc ??= json['fullDescription']?.toString();
    desc ??= json['description']?.toString();

    return AladinItem(
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      isbn13: json['isbn13']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      pageCount: pages,
      description: desc,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v > 0 ? v : null;
    if (v is String) {
      final digits = RegExp(r'\d+').stringMatch(v);
      final parsed = int.tryParse(digits ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  Book toEntity() {
    return Book(
      id: isbn13.isNotEmpty
          ? isbn13
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author.isNotEmpty ? author : '알 수 없는 저자',
      coverImageUrl: cover,
      totalPages: pageCount ?? 200,
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
}

/// ItemLookUp 전용 상세 모델 (필요 시 사용)
class AladinItemDetail {
  final String title;
  final String author;
  final String publisher;
  final String isbn13;
  final String cover;
  final int? pageCount;
  final String? description;

  const AladinItemDetail({
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn13,
    required this.cover,
    required this.pageCount,
    required this.description,
  });

  factory AladinItemDetail.fromJson(Map<String, dynamic> json) {
    int? pages;
    final subInfo = json['subInfo'];
    if (subInfo is Map<String, dynamic>) {
      pages = AladinItem._parseInt(subInfo['itemPage']);
    }
    pages ??= AladinItem._parseInt(json['itemPage']);

    String? desc;
    if (subInfo is Map<String, dynamic>) {
      desc = (subInfo['fullDescription'] ?? subInfo['description'])?.toString();
    }
    desc ??= json['fullDescription']?.toString();
    desc ??= json['description']?.toString();

    return AladinItemDetail(
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      isbn13: json['isbn13']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      pageCount: pages,
      description: desc,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_note.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
class BookModel with _$BookModel {
  const factory BookModel({
    required String bookId,
    required String title,
    required String author,
    String? thumbnail,
    String? description,
    @Default(0) int totalPages,
    @Default(0) int currentPage,
    @Default('planned') String status,
    required String createdAt,
    String? startedAt,
    String? completedAt,
    required String updatedAt,
    String? lastReadAt,
    String? coverImageUrl,
    String? startDate,
    String? memo,
    String? themeColor,
    @Default(0) int priority,
    @Default(0) int isFavorite,
    @Default([]) List<Map<String, dynamic>> notes,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  // Firebase Firestore에서 변환
  factory BookModel.fromFirestore(Map<String, dynamic> data) {
    return BookModel(
      bookId: data['id'] ?? data['bookId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      thumbnail: data['thumbnail'],
      description: data['description'],
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 0,
      status: data['status'] ?? 'planned',
      createdAt: _parseTimestamp(data['createdAt']),
      startedAt: _parseTimestamp(data['startedAt']),
      completedAt: _parseTimestamp(data['completedAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastReadAt: _parseTimestamp(data['lastReadAt']),
      coverImageUrl: data['coverImageUrl'],
      startDate: data['startDate'],
      memo: data['memo'],
      themeColor: data['themeColor'],
      priority: data['priority'] ?? 0,
      isFavorite: data['isFavorite'] ?? 0,
      notes: List<Map<String, dynamic>>.from(data['notes'] ?? []),
    );
  }

  // Book 엔티티에서 변환
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      bookId: book.id,
      title: book.title,
      author: book.author,
      thumbnail: book.coverImageUrl.isNotEmpty ? book.coverImageUrl : null,
      description: null, // Book 엔티티에 description이 없음
      totalPages: book.totalPages,
      currentPage: book.currentPage,
      status: book.status.toString().split('.').last,
      createdAt: book.createdAt.toIso8601String(),
      startedAt: book.startedAt?.toIso8601String(),
      completedAt: book.completedAt?.toIso8601String(),
      updatedAt: book.updatedAt.toIso8601String(),
      lastReadAt: book.lastReadAt?.toIso8601String(),
      coverImageUrl: book.coverImageUrl.isNotEmpty ? book.coverImageUrl : null,
      startDate: null,
      memo: book.memo,
      themeColor: null,
      priority: book.priority,
      isFavorite: book.isFavorite ? 1 : 0,
      notes: book.notes
          .map((note) => {
                'id': note.id,
                'title': note.title,
                'content': note.content,
                'pageNumber': note.pageNumber,
                'createdAt': note.createdAt.toIso8601String(),
                'updatedAt': note.updatedAt.toIso8601String(),
              })
          .toList(),
    );
  }

  // Database Map에서 변환
  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      thumbnail: map['thumbnail'] as String?,
      description: map['description'] as String?,
      totalPages: map['totalPages'] as int? ?? 0,
      currentPage: map['currentPage'] as int? ?? 0,
      status: map['status'] as String? ?? 'planned',
      createdAt:
          map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      startedAt: map['startedAt'] as String?,
      completedAt: map['completedAt'] as String?,
      updatedAt:
          map['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      lastReadAt: map['lastReadAt'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      startDate: map['startDate'] as String?,
      memo: map['memo'] as String?,
      themeColor: map['themeColor'] as String?,
      priority: map['priority'] as int? ?? 0,
      isFavorite: map['isFavorite'] as int? ?? 0,
      notes: [],
    );
  }

  // Helper method for parsing Firestore timestamps
  static String _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    if (timestamp is String) return timestamp;
    // Firestore Timestamp 객체인 경우
    if (timestamp.runtimeType.toString() == 'Timestamp') {
      return (timestamp as dynamic).toDate().toIso8601String();
    }
    return DateTime.now().toIso8601String();
  }
}

// Extension methods for business logic
extension BookModelX on BookModel {
  // Domain Entity로 변환
  Book toEntity() {
    return Book(
      id: bookId,
      title: title,
      author: author,
      coverImageUrl: coverImageUrl ?? '',
      totalPages: totalPages,
      currentPage: currentPage,
      status: _parseBookStatus(status),
      createdAt: DateTime.parse(createdAt),
      startedAt: startedAt != null ? DateTime.parse(startedAt!) : null,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      updatedAt: DateTime.parse(updatedAt),
      lastReadAt: lastReadAt != null ? DateTime.parse(lastReadAt!) : null,
      readingSessions: [], // 별도 로드 필요
      memo: memo,
      notes: _parseNotes(notes),
      themeColor: null, // Color 파싱 로직 필요시 추가
      priority: priority,
      isFavorite: isFavorite == 1,
    );
  }

  // Firebase Firestore로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
      'description': description,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'lastReadAt': lastReadAt,
      'coverImageUrl': coverImageUrl,
      'startDate': startDate,
      'memo': memo,
      'themeColor': themeColor,
      'priority': priority,
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }

  // Database Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
      'description': description,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'updatedAt': updatedAt,
      'lastReadAt': lastReadAt,
      'coverImageUrl': coverImageUrl,
      'startDate': startDate,
      'memo': memo,
      'themeColor': themeColor,
      'priority': priority,
      'isFavorite': isFavorite,
    };
  }

  // Helper method for parsing book status
  BookStatus _parseBookStatus(String status) {
    switch (status) {
      case 'reading':
        return BookStatus.reading;
      case 'completed':
        return BookStatus.completed;
      case 'planned':
      default:
        return BookStatus.planned;
    }
  }

  // Helper method for parsing notes
  List<ReadingNote> _parseNotes(List<Map<String, dynamic>> notesData) {
    return notesData.map((noteData) {
      final createdAt = DateTime.parse(
          noteData['createdAt'] ?? DateTime.now().toIso8601String());
      return ReadingNote(
        id: noteData['id'] ?? '',
        title: noteData['title'] ?? '',
        content: noteData['content'] ?? '',
        pageNumber: noteData['pageNumber'] ?? 0,
        createdAt: createdAt,
        updatedAt: DateTime.parse(
            noteData['updatedAt'] ?? createdAt.toIso8601String()),
      );
    }).toList();
  }

  // Helper method for serializing notes
  static List<Map<String, dynamic>> _serializeNotes(List<ReadingNote> notes) {
    return notes
        .map((note) => {
              'id': note.id,
              'title': note.title,
              'content': note.content,
              'pageNumber': note.pageNumber,
              'createdAt': note.createdAt.toIso8601String(),
              'updatedAt': note.updatedAt.toIso8601String(),
            })
        .toList();
  }
}

import 'package:flutter/material.dart';
import 'reading_note.dart';

enum BookStatus { planned, reading, completed, paused }

class Book {
  final String id;
  final String title;
  final String author;
  final String coverImageUrl;
  final int totalPages;
  final int currentPage;
  final BookStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final DateTime? lastReadAt;
  final List<ReadingSession> readingSessions;
  final String? memo;
  final List<ReadingNote> notes;
  final Color? themeColor;
  final int priority;
  final bool isFavorite;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
    this.lastReadAt,
    required this.readingSessions,
    this.memo,
    required this.notes,
    this.themeColor,
    this.priority = 0,
    this.isFavorite = false,
  });

  double get readingProgress => totalPages > 0 ? currentPage / totalPages : 0;

  bool get isCompleted => status == BookStatus.completed;
  bool get isReading => status == BookStatus.reading;
  bool get isPlanned => status == BookStatus.planned;
  bool get isPaused => status == BookStatus.paused;

  int get totalReadingTime => readingSessions.fold(
    0,
    (total, session) => total + session.duration.inMinutes,
  );

  // 최근 활동 기준 날짜 (정렬용)
  DateTime get sortDate => lastReadAt ?? updatedAt;

  // 상태별 우선순위 (정렬용)
  int get statusPriority {
    switch (status) {
      case BookStatus.reading:
        return 1;
      case BookStatus.paused:
        return 2;
      case BookStatus.planned:
        return 3;
      case BookStatus.completed:
        return 4;
    }
  }

  // 즐겨찾기나 우선순위가 높은 책인지 확인
  bool get isHighPriority => isFavorite || priority > 0;

  // Book 엔티티 복사 메서드 (상태 변경 등에 사용)
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverImageUrl,
    int? totalPages,
    int? currentPage,
    BookStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? lastReadAt,
    List<ReadingSession>? readingSessions,
    String? memo,
    List<ReadingNote>? notes,
    Color? themeColor,
    int? priority,
    bool? isFavorite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingSessions: readingSessions ?? this.readingSessions,
      memo: memo ?? this.memo,
      notes: notes ?? this.notes,
      themeColor: themeColor ?? this.themeColor,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ReadingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int startPage;
  final int endPage;
  final String? memo;
  final DateTime createdAt;

  const ReadingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.startPage,
    required this.endPage,
    this.memo,
    required this.createdAt,
  });

  Duration get duration => endTime.difference(startTime);
  int get pagesRead => endPage - startPage;

  // 읽은 페이지 수를 분당 속도로 계산
  double get readingSpeed {
    final minutes = duration.inMinutes;
    return minutes > 0 ? pagesRead / minutes : 0;
  }
}

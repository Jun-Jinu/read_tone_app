class ReadingNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? pageNumber;

  const ReadingNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.pageNumber,
  });

  ReadingNote copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pageNumber,
  }) {
    return ReadingNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pageNumber': pageNumber,
    };
  }

  factory ReadingNote.fromMap(Map<String, dynamic> map) {
    return ReadingNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      pageNumber: map['pageNumber'],
    );
  }

  @override
  String toString() {
    return 'ReadingNote(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, pageNumber: $pageNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingNote && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

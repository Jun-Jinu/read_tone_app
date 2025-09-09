// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookModelImpl _$$BookModelImplFromJson(Map<String, dynamic> json) =>
    _$BookModelImpl(
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      thumbnail: json['thumbnail'] as String?,
      description: json['description'] as String?,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'planned',
      createdAt: json['createdAt'] as String,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      updatedAt: json['updatedAt'] as String,
      lastReadAt: json['lastReadAt'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      startDate: json['startDate'] as String?,
      memo: json['memo'] as String?,
      themeColor: json['themeColor'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      isFavorite: (json['isFavorite'] as num?)?.toInt() ?? 0,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BookModelImplToJson(_$BookModelImpl instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'author': instance.author,
      'thumbnail': instance.thumbnail,
      'description': instance.description,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'startedAt': instance.startedAt,
      'completedAt': instance.completedAt,
      'updatedAt': instance.updatedAt,
      'lastReadAt': instance.lastReadAt,
      'coverImageUrl': instance.coverImageUrl,
      'startDate': instance.startDate,
      'memo': instance.memo,
      'themeColor': instance.themeColor,
      'priority': instance.priority,
      'isFavorite': instance.isFavorite,
      'notes': instance.notes,
    };

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookModel _$BookModelFromJson(Map<String, dynamic> json) {
  return _BookModel.fromJson(json);
}

/// @nodoc
mixin _$BookModel {
  String get bookId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get startedAt => throw _privateConstructorUsedError;
  String? get completedAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get lastReadAt => throw _privateConstructorUsedError;
  String? get coverImageUrl => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  String? get themeColor => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  int get isFavorite => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get notes => throw _privateConstructorUsedError;

  /// Serializes this BookModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookModelCopyWith<BookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookModelCopyWith<$Res> {
  factory $BookModelCopyWith(BookModel value, $Res Function(BookModel) then) =
      _$BookModelCopyWithImpl<$Res, BookModel>;
  @useResult
  $Res call({
    String bookId,
    String title,
    String author,
    String? thumbnail,
    String? description,
    int totalPages,
    int currentPage,
    String status,
    String createdAt,
    String? startedAt,
    String? completedAt,
    String updatedAt,
    String? lastReadAt,
    String? coverImageUrl,
    String? startDate,
    String? memo,
    String? themeColor,
    int priority,
    int isFavorite,
    List<Map<String, dynamic>> notes,
  });
}

/// @nodoc
class _$BookModelCopyWithImpl<$Res, $Val extends BookModel>
    implements $BookModelCopyWith<$Res> {
  _$BookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? title = null,
    Object? author = null,
    Object? thumbnail = freezed,
    Object? description = freezed,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? status = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? updatedAt = null,
    Object? lastReadAt = freezed,
    Object? coverImageUrl = freezed,
    Object? startDate = freezed,
    Object? memo = freezed,
    Object? themeColor = freezed,
    Object? priority = null,
    Object? isFavorite = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnail: freezed == thumbnail
                ? _value.thumbnail
                : thumbnail // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            lastReadAt: freezed == lastReadAt
                ? _value.lastReadAt
                : lastReadAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            themeColor: freezed == themeColor
                ? _value.themeColor
                : themeColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookModelImplCopyWith<$Res>
    implements $BookModelCopyWith<$Res> {
  factory _$$BookModelImplCopyWith(
    _$BookModelImpl value,
    $Res Function(_$BookModelImpl) then,
  ) = __$$BookModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String bookId,
    String title,
    String author,
    String? thumbnail,
    String? description,
    int totalPages,
    int currentPage,
    String status,
    String createdAt,
    String? startedAt,
    String? completedAt,
    String updatedAt,
    String? lastReadAt,
    String? coverImageUrl,
    String? startDate,
    String? memo,
    String? themeColor,
    int priority,
    int isFavorite,
    List<Map<String, dynamic>> notes,
  });
}

/// @nodoc
class __$$BookModelImplCopyWithImpl<$Res>
    extends _$BookModelCopyWithImpl<$Res, _$BookModelImpl>
    implements _$$BookModelImplCopyWith<$Res> {
  __$$BookModelImplCopyWithImpl(
    _$BookModelImpl _value,
    $Res Function(_$BookModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? title = null,
    Object? author = null,
    Object? thumbnail = freezed,
    Object? description = freezed,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? status = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? updatedAt = null,
    Object? lastReadAt = freezed,
    Object? coverImageUrl = freezed,
    Object? startDate = freezed,
    Object? memo = freezed,
    Object? themeColor = freezed,
    Object? priority = null,
    Object? isFavorite = null,
    Object? notes = null,
  }) {
    return _then(
      _$BookModelImpl(
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnail: freezed == thumbnail
            ? _value.thumbnail
            : thumbnail // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        lastReadAt: freezed == lastReadAt
            ? _value.lastReadAt
            : lastReadAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        themeColor: freezed == themeColor
            ? _value.themeColor
            : themeColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: null == notes
            ? _value._notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookModelImpl implements _BookModel {
  const _$BookModelImpl({
    required this.bookId,
    required this.title,
    required this.author,
    this.thumbnail,
    this.description,
    this.totalPages = 0,
    this.currentPage = 0,
    this.status = 'planned',
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
    this.lastReadAt,
    this.coverImageUrl,
    this.startDate,
    this.memo,
    this.themeColor,
    this.priority = 0,
    this.isFavorite = 0,
    final List<Map<String, dynamic>> notes = const [],
  }) : _notes = notes;

  factory _$BookModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookModelImplFromJson(json);

  @override
  final String bookId;
  @override
  final String title;
  @override
  final String author;
  @override
  final String? thumbnail;
  @override
  final String? description;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final String status;
  @override
  final String createdAt;
  @override
  final String? startedAt;
  @override
  final String? completedAt;
  @override
  final String updatedAt;
  @override
  final String? lastReadAt;
  @override
  final String? coverImageUrl;
  @override
  final String? startDate;
  @override
  final String? memo;
  @override
  final String? themeColor;
  @override
  @JsonKey()
  final int priority;
  @override
  @JsonKey()
  final int isFavorite;
  final List<Map<String, dynamic>> _notes;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'BookModel(bookId: $bookId, title: $title, author: $author, thumbnail: $thumbnail, description: $description, totalPages: $totalPages, currentPage: $currentPage, status: $status, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, updatedAt: $updatedAt, lastReadAt: $lastReadAt, coverImageUrl: $coverImageUrl, startDate: $startDate, memo: $memo, themeColor: $themeColor, priority: $priority, isFavorite: $isFavorite, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookModelImpl &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.themeColor, themeColor) ||
                other.themeColor == themeColor) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    bookId,
    title,
    author,
    thumbnail,
    description,
    totalPages,
    currentPage,
    status,
    createdAt,
    startedAt,
    completedAt,
    updatedAt,
    lastReadAt,
    coverImageUrl,
    startDate,
    memo,
    themeColor,
    priority,
    isFavorite,
    const DeepCollectionEquality().hash(_notes),
  ]);

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      __$$BookModelImplCopyWithImpl<_$BookModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookModelImplToJson(this);
  }
}

abstract class _BookModel implements BookModel {
  const factory _BookModel({
    required final String bookId,
    required final String title,
    required final String author,
    final String? thumbnail,
    final String? description,
    final int totalPages,
    final int currentPage,
    final String status,
    required final String createdAt,
    final String? startedAt,
    final String? completedAt,
    required final String updatedAt,
    final String? lastReadAt,
    final String? coverImageUrl,
    final String? startDate,
    final String? memo,
    final String? themeColor,
    final int priority,
    final int isFavorite,
    final List<Map<String, dynamic>> notes,
  }) = _$BookModelImpl;

  factory _BookModel.fromJson(Map<String, dynamic> json) =
      _$BookModelImpl.fromJson;

  @override
  String get bookId;
  @override
  String get title;
  @override
  String get author;
  @override
  String? get thumbnail;
  @override
  String? get description;
  @override
  int get totalPages;
  @override
  int get currentPage;
  @override
  String get status;
  @override
  String get createdAt;
  @override
  String? get startedAt;
  @override
  String? get completedAt;
  @override
  String get updatedAt;
  @override
  String? get lastReadAt;
  @override
  String? get coverImageUrl;
  @override
  String? get startDate;
  @override
  String? get memo;
  @override
  String? get themeColor;
  @override
  int get priority;
  @override
  int get isFavorite;
  @override
  List<Map<String, dynamic>> get notes;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

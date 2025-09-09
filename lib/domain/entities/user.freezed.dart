// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$User {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  int get totalBooksRead => throw _privateConstructorUsedError;
  int get totalReadingTime => throw _privateConstructorUsedError; // 분 단위
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get themeMode => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get emailNotificationsEnabled => throw _privateConstructorUsedError;
  int get dailyReadingGoal => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? birthDate,
    String? bio,
    int totalBooksRead,
    int totalReadingTime,
    int currentStreak,
    int longestStreak,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastLoginAt,
    bool isPremium,
    String language,
    String themeMode,
    bool notificationsEnabled,
    bool emailNotificationsEnabled,
    int dailyReadingGoal,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? profileImageUrl = freezed,
    Object? phoneNumber = freezed,
    Object? birthDate = freezed,
    Object? bio = freezed,
    Object? totalBooksRead = null,
    Object? totalReadingTime = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
    Object? isPremium = null,
    Object? language = null,
    Object? themeMode = null,
    Object? notificationsEnabled = null,
    Object? emailNotificationsEnabled = null,
    Object? dailyReadingGoal = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthDate: freezed == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalBooksRead: null == totalBooksRead
                ? _value.totalBooksRead
                : totalBooksRead // ignore: cast_nullable_to_non_nullable
                      as int,
            totalReadingTime: null == totalReadingTime
                ? _value.totalReadingTime
                : totalReadingTime // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailNotificationsEnabled: null == emailNotificationsEnabled
                ? _value.emailNotificationsEnabled
                : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            dailyReadingGoal: null == dailyReadingGoal
                ? _value.dailyReadingGoal
                : dailyReadingGoal // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? birthDate,
    String? bio,
    int totalBooksRead,
    int totalReadingTime,
    int currentStreak,
    int longestStreak,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastLoginAt,
    bool isPremium,
    String language,
    String themeMode,
    bool notificationsEnabled,
    bool emailNotificationsEnabled,
    int dailyReadingGoal,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? profileImageUrl = freezed,
    Object? phoneNumber = freezed,
    Object? birthDate = freezed,
    Object? bio = freezed,
    Object? totalBooksRead = null,
    Object? totalReadingTime = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
    Object? isPremium = null,
    Object? language = null,
    Object? themeMode = null,
    Object? notificationsEnabled = null,
    Object? emailNotificationsEnabled = null,
    Object? dailyReadingGoal = null,
  }) {
    return _then(
      _$UserImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthDate: freezed == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalBooksRead: null == totalBooksRead
            ? _value.totalBooksRead
            : totalBooksRead // ignore: cast_nullable_to_non_nullable
                  as int,
        totalReadingTime: null == totalReadingTime
            ? _value.totalReadingTime
            : totalReadingTime // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailNotificationsEnabled: null == emailNotificationsEnabled
            ? _value.emailNotificationsEnabled
            : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        dailyReadingGoal: null == dailyReadingGoal
            ? _value.dailyReadingGoal
            : dailyReadingGoal // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$UserImpl extends _User {
  const _$UserImpl({
    required this.uid,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.phoneNumber,
    this.birthDate,
    this.bio,
    this.totalBooksRead = 0,
    this.totalReadingTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.language = 'ko',
    this.themeMode = 'light',
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.dailyReadingGoal = 30,
  }) : super._();

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? profileImageUrl;
  @override
  final String? phoneNumber;
  @override
  final DateTime? birthDate;
  @override
  final String? bio;
  @override
  @JsonKey()
  final int totalBooksRead;
  @override
  @JsonKey()
  final int totalReadingTime;
  // 분 단위
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? lastLoginAt;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String themeMode;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool emailNotificationsEnabled;
  @override
  @JsonKey()
  final int dailyReadingGoal;

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, profileImageUrl: $profileImageUrl, phoneNumber: $phoneNumber, birthDate: $birthDate, bio: $bio, totalBooksRead: $totalBooksRead, totalReadingTime: $totalReadingTime, currentStreak: $currentStreak, longestStreak: $longestStreak, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, isPremium: $isPremium, language: $language, themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, emailNotificationsEnabled: $emailNotificationsEnabled, dailyReadingGoal: $dailyReadingGoal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.totalBooksRead, totalBooksRead) ||
                other.totalBooksRead == totalBooksRead) &&
            (identical(other.totalReadingTime, totalReadingTime) ||
                other.totalReadingTime == totalReadingTime) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(
                  other.emailNotificationsEnabled,
                  emailNotificationsEnabled,
                ) ||
                other.emailNotificationsEnabled == emailNotificationsEnabled) &&
            (identical(other.dailyReadingGoal, dailyReadingGoal) ||
                other.dailyReadingGoal == dailyReadingGoal));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    uid,
    email,
    displayName,
    profileImageUrl,
    phoneNumber,
    birthDate,
    bio,
    totalBooksRead,
    totalReadingTime,
    currentStreak,
    longestStreak,
    createdAt,
    updatedAt,
    lastLoginAt,
    isPremium,
    language,
    themeMode,
    notificationsEnabled,
    emailNotificationsEnabled,
    dailyReadingGoal,
  ]);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);
}

abstract class _User extends User {
  const factory _User({
    required final String uid,
    required final String email,
    final String? displayName,
    final String? profileImageUrl,
    final String? phoneNumber,
    final DateTime? birthDate,
    final String? bio,
    final int totalBooksRead,
    final int totalReadingTime,
    final int currentStreak,
    final int longestStreak,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastLoginAt,
    final bool isPremium,
    final String language,
    final String themeMode,
    final bool notificationsEnabled,
    final bool emailNotificationsEnabled,
    final int dailyReadingGoal,
  }) = _$UserImpl;
  const _User._() : super._();

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get profileImageUrl;
  @override
  String? get phoneNumber;
  @override
  DateTime? get birthDate;
  @override
  String? get bio;
  @override
  int get totalBooksRead;
  @override
  int get totalReadingTime; // 분 단위
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get lastLoginAt;
  @override
  bool get isPremium;
  @override
  String get language;
  @override
  String get themeMode;
  @override
  bool get notificationsEnabled;
  @override
  bool get emailNotificationsEnabled;
  @override
  int get dailyReadingGoal;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

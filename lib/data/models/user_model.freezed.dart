// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  int get totalBooksRead => throw _privateConstructorUsedError;
  int get totalReadingTime => throw _privateConstructorUsedError;
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

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
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
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
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
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
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
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
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
      _$UserModelImpl(
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
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
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

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

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
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, profileImageUrl: $profileImageUrl, phoneNumber: $phoneNumber, birthDate: $birthDate, bio: $bio, totalBooksRead: $totalBooksRead, totalReadingTime: $totalReadingTime, currentStreak: $currentStreak, longestStreak: $longestStreak, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, isPremium: $isPremium, language: $language, themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, emailNotificationsEnabled: $emailNotificationsEnabled, dailyReadingGoal: $dailyReadingGoal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
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
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

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
  int get totalReadingTime;
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

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

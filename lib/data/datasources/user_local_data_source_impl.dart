import 'package:sqflite/sqflite.dart';
import '../../core/utils/database_service.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  @override
  Future<User?> getCurrentUser() async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'users',
      limit: 1,
    );

    if (result.isEmpty) return null;

    final userData = result.first;
    return UserModel.fromMap(userData).toEntity();
  }

  @override
  Future<void> saveUser(User user) async {
    final db = await DatabaseService.database;
    final userModel = UserModel.fromEntity(user);

    await db.insert(
      'users',
      userModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await DatabaseService.database;
    final userModel = UserModel.fromEntity(user);

    await db.update(
      'users',
      userModel.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    final db = await DatabaseService.database;

    await db.delete(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<void> clearAllUserData() async {
    final db = await DatabaseService.database;

    // 모든 사용자 데이터 삭제
    await db.delete('users');
  }

  @override
  Future<bool> userExists(String uid) async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  @override
  Future<void> updateUserSettings({
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    int? dailyReadingGoal,
  }) async {
    final db = await DatabaseService.database;

    // 현재 사용자 가져오기
    final currentUser = await getCurrentUser();
    if (currentUser == null) return;

    final updateData = <String, dynamic>{};

    if (language != null) updateData['language'] = language;
    if (themeMode != null) updateData['themeMode'] = themeMode;
    if (notificationsEnabled != null)
      updateData['notificationsEnabled'] = notificationsEnabled ? 1 : 0;
    if (emailNotificationsEnabled != null)
      updateData['emailNotificationsEnabled'] =
          emailNotificationsEnabled ? 1 : 0;
    if (dailyReadingGoal != null)
      updateData['dailyReadingGoal'] = dailyReadingGoal;

    updateData['updatedAt'] = DateTime.now().toIso8601String();

    await db.update(
      'users',
      updateData,
      where: 'uid = ?',
      whereArgs: [currentUser.uid],
    );
  }

  @override
  Future<void> updateReadingStats({
    int? totalBooksRead,
    int? totalReadingTime,
    int? currentStreak,
    int? longestStreak,
  }) async {
    final db = await DatabaseService.database;

    // 현재 사용자 가져오기
    final currentUser = await getCurrentUser();
    if (currentUser == null) return;

    final updateData = <String, dynamic>{};

    if (totalBooksRead != null) updateData['totalBooksRead'] = totalBooksRead;
    if (totalReadingTime != null)
      updateData['totalReadingTime'] = totalReadingTime;
    if (currentStreak != null) updateData['currentStreak'] = currentStreak;
    if (longestStreak != null) updateData['longestStreak'] = longestStreak;

    updateData['updatedAt'] = DateTime.now().toIso8601String();

    await db.update(
      'users',
      updateData,
      where: 'uid = ?',
      whereArgs: [currentUser.uid],
    );
  }
}

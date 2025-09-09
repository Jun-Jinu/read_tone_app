import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

// 웹용 import
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.io) '';

class DatabaseService {
  static Database? _database;
  static const String databaseName = 'read_tone.db';

  // 데이터베이스 인스턴스 가져오기
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화
  static Future<Database> _initDatabase() async {
    // 웹 플랫폼에서는 sqflite_common_ffi 사용
    if (kIsWeb) {
      return await _initWebDatabase();
    }

    final String path = join(await getDatabasesPath(), databaseName);

    return await openDatabase(
      path,
      version: 4, // 버전을 4로 업그레이드 (사용자 테이블 개선)
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  // 웹용 데이터베이스 초기화
  static Future<Database> _initWebDatabase() async {
    // 웹에서는 localStorage 기반 데이터베이스 사용
    if (kIsWeb) {
      // 웹에서는 임시로 더미 데이터 반환
      return await openDatabase(
        inMemoryDatabasePath,
        version: 4,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
    }

    return await openDatabase(
      ':memory:', // 인메모리 데이터베이스
      version: 4,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  // 데이터베이스 테이블 생성
  static Future<void> _createTables(Database db, int version) async {
    // 책 테이블 (개선된 버전)
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        thumbnail TEXT,
        description TEXT,
        totalPages INTEGER NOT NULL DEFAULT 0,
        currentPage INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'planned',
        createdAt TEXT NOT NULL,
        startedAt TEXT,
        completedAt TEXT,
        updatedAt TEXT NOT NULL,
        lastReadAt TEXT,
        coverImageUrl TEXT,
        startDate TEXT,
        memo TEXT,
        themeColor TEXT,
        -- 정렬 우선순위를 위한 필드
        priority INTEGER NOT NULL DEFAULT 0,
        -- 즐겨찾기 기능
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 효율적인 조회를 위한 인덱스들
    await _createBookIndexes(db);

    // 독서 세션 테이블 (개선된 버전)
    await db.execute('''
      CREATE TABLE reading_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT UNIQUE NOT NULL,
        bookId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        startPage INTEGER NOT NULL,
        endPage INTEGER NOT NULL,
        duration INTEGER NOT NULL, -- 분 단위로 저장
        memo TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (bookId) ON DELETE CASCADE
      )
    ''');

    // 독서 세션 인덱스
    await db.execute(
        'CREATE INDEX idx_reading_sessions_book_id ON reading_sessions(bookId)');
    await db.execute(
        'CREATE INDEX idx_reading_sessions_start_time ON reading_sessions(startTime DESC)');

    // 독서 로그 테이블
    await db.execute('''
      CREATE TABLE reading_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        logId TEXT UNIQUE,
        bookId TEXT NOT NULL,
        userId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        startPage INTEGER NOT NULL,
        endPage INTEGER,
        memo TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (bookId) ON DELETE CASCADE
      )
    ''');

    // 독서 로그 인덱스
    await db.execute(
        'CREATE INDEX idx_reading_logs_book_id ON reading_logs(bookId)');
    await db.execute(
        'CREATE INDEX idx_reading_logs_start_time ON reading_logs(startTime DESC)');

    // 리뷰 테이블
    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reviewId TEXT UNIQUE,
        bookId TEXT NOT NULL,
        userId TEXT NOT NULL,
        content TEXT NOT NULL,
        rating INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (bookId) ON DELETE CASCADE
      )
    ''');

    // 리뷰 태그 테이블 (리뷰와 다대다 관계)
    await db.execute('''
      CREATE TABLE review_tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reviewId TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY (reviewId) REFERENCES reviews (reviewId) ON DELETE CASCADE
      )
    ''');

    // 목표 테이블
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId TEXT UNIQUE,
        userId TEXT NOT NULL,
        targetPages INTEGER NOT NULL,
        currentPages INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        goalType TEXT NOT NULL
      )
    ''');

    // 사용자 테이블 (개선된 버전)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        displayName TEXT,
        profileImageUrl TEXT,
        phoneNumber TEXT,
        birthDate TEXT,
        bio TEXT,
        totalBooksRead INTEGER NOT NULL DEFAULT 0,
        totalReadingTime INTEGER NOT NULL DEFAULT 0,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        longestStreak INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        lastLoginAt TEXT,
        isPremium INTEGER NOT NULL DEFAULT 0,
        language TEXT NOT NULL DEFAULT 'ko',
        themeMode TEXT NOT NULL DEFAULT 'light',
        notificationsEnabled INTEGER NOT NULL DEFAULT 1,
        emailNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
        dailyReadingGoal INTEGER NOT NULL DEFAULT 30
      )
    ''');

    // 최근 활동을 위한 뷰 생성
    await _createViews(db);
  }

  // 책 테이블 인덱스 생성
  static Future<void> _createBookIndexes(Database db) async {
    // 상태별 조회를 위한 인덱스
    await db.execute('CREATE INDEX idx_books_status ON books(status)');

    // 최근 활동 기준 정렬을 위한 복합 인덱스 (SQLite 호환)
    await db.execute(
        'CREATE INDEX idx_books_recent_activity ON books(status, COALESCE(lastReadAt, updatedAt) DESC, updatedAt DESC)');

    // 생성일 기준 정렬을 위한 인덱스
    await db
        .execute('CREATE INDEX idx_books_created_at ON books(createdAt DESC)');

    // 완료일 기준 정렬을 위한 인덱스 (SQLite 호환)
    await db.execute(
        'CREATE INDEX idx_books_completed_at ON books(COALESCE(completedAt, updatedAt) DESC)');

    // 시작일 기준 정렬을 위한 인덱스 (SQLite 호환)
    await db.execute(
        'CREATE INDEX idx_books_started_at ON books(COALESCE(startedAt, updatedAt) DESC)');

    // 업데이트일 기준 정렬을 위한 인덱스
    await db
        .execute('CREATE INDEX idx_books_updated_at ON books(updatedAt DESC)');

    // 즐겨찾기 + 상태별 조회를 위한 복합 인덱스 (SQLite 호환)
    await db.execute(
        'CREATE INDEX idx_books_favorite_status ON books(isFavorite DESC, status, COALESCE(lastReadAt, updatedAt) DESC)');

    // 우선순위 + 상태별 조회를 위한 복합 인덱스 (SQLite 호환)
    await db.execute(
        'CREATE INDEX idx_books_priority_status ON books(priority DESC, status, COALESCE(lastReadAt, updatedAt) DESC)');
  }

  // 효율적인 조회를 위한 뷰 생성
  static Future<void> _createViews(Database db) async {
    // 최근 활동 책들을 위한 뷰
    await db.execute('''
      CREATE VIEW recent_books_view AS
      SELECT 
        b.*,
        COALESCE(b.lastReadAt, b.updatedAt, b.createdAt) as sortDate,
        CASE 
          WHEN b.status = 'reading' THEN 1
          WHEN b.status = 'planned' THEN 2
          WHEN b.status = 'completed' THEN 3
          ELSE 4
        END as statusPriority
      FROM books b
      ORDER BY 
        b.isFavorite DESC,
        statusPriority ASC,
        sortDate DESC
    ''');

    // 각 상태별 최근 책들을 위한 뷰
    await db.execute('''
      CREATE VIEW reading_books_view AS
      SELECT b.*, 
             COALESCE(b.lastReadAt, b.startedAt, b.updatedAt) as sortDate
      FROM books b 
      WHERE b.status = 'reading'
      ORDER BY b.isFavorite DESC, sortDate DESC
    ''');

    await db.execute('''
      CREATE VIEW planned_books_view AS
      SELECT b.*, b.createdAt as sortDate
      FROM books b 
      WHERE b.status = 'planned'
      ORDER BY b.isFavorite DESC, b.priority DESC, sortDate DESC
    ''');

    await db.execute('''
      CREATE VIEW completed_books_view AS
      SELECT b.*, b.completedAt as sortDate
      FROM books b 
      WHERE b.status = 'completed'
      ORDER BY b.isFavorite DESC, sortDate DESC
    ''');
  }

  // 데이터베이스 업그레이드
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 버전 1에서 2로 업그레이드: 새로운 필드들 추가
      await db.execute('ALTER TABLE books ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN lastReadAt TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN memo TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN themeColor TEXT');
      await db.execute(
          'ALTER TABLE books ADD COLUMN priority INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE books ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');

      // 기존 데이터의 updatedAt을 createdAt 또는 현재 시간으로 설정
      await db.execute('''
        UPDATE books 
        SET updatedAt = COALESCE(startDate, datetime('now')) 
        WHERE updatedAt IS NULL
      ''');

      // 독서 세션 테이블에 새 필드 추가
      await db
          .execute('ALTER TABLE reading_sessions ADD COLUMN sessionId TEXT');
      await db
          .execute('ALTER TABLE reading_sessions ADD COLUMN duration INTEGER');
      await db
          .execute('ALTER TABLE reading_sessions ADD COLUMN createdAt TEXT');

      // 기존 세션들에 대해 계산된 값들 업데이트
      await db.execute('''
        UPDATE reading_sessions 
        SET sessionId = 'session_' || id,
            duration = (julianday(endTime) - julianday(startTime)) * 24 * 60,
            createdAt = startTime
        WHERE sessionId IS NULL
      ''');
    }

    if (oldVersion < 3) {
      // 버전 2에서 3으로 업그레이드: SQLite 호환 인덱스로 재생성
      try {
        // 기존 인덱스들 삭제 (존재하는 경우에만)
        await db.execute('DROP INDEX IF EXISTS idx_books_recent_activity');
        await db.execute('DROP INDEX IF EXISTS idx_books_completed_at');
        await db.execute('DROP INDEX IF EXISTS idx_books_started_at');
        await db.execute('DROP INDEX IF EXISTS idx_books_favorite_status');
        await db.execute('DROP INDEX IF EXISTS idx_books_priority_status');

        // 기존 뷰들 삭제 (존재하는 경우에만)
        await db.execute('DROP VIEW IF EXISTS recent_books_view');
        await db.execute('DROP VIEW IF EXISTS reading_books_view');
        await db.execute('DROP VIEW IF EXISTS planned_books_view');
        await db.execute('DROP VIEW IF EXISTS completed_books_view');

        // SQLite 호환 인덱스들 재생성
        await _createBookIndexes(db);
        await _createViews(db);
      } catch (e) {
        print('인덱스 업그레이드 중 오류 발생: $e');
        // 오류가 발생해도 계속 진행
      }
    }

    if (oldVersion < 4) {
      // 버전 3에서 4로 업그레이드: 사용자 테이블 개선
      try {
        // 기존 users 테이블 백업
        await db.execute('''
          CREATE TABLE users_backup AS SELECT * FROM users
        ''');

        // 기존 users 테이블 삭제
        await db.execute('DROP TABLE users');

        // 새로운 users 테이블 생성
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT UNIQUE NOT NULL,
            email TEXT NOT NULL,
            displayName TEXT,
            profileImageUrl TEXT,
            phoneNumber TEXT,
            birthDate TEXT,
            bio TEXT,
            totalBooksRead INTEGER NOT NULL DEFAULT 0,
            totalReadingTime INTEGER NOT NULL DEFAULT 0,
            currentStreak INTEGER NOT NULL DEFAULT 0,
            longestStreak INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            lastLoginAt TEXT,
            isPremium INTEGER NOT NULL DEFAULT 0,
            language TEXT NOT NULL DEFAULT 'ko',
            themeMode TEXT NOT NULL DEFAULT 'light',
            notificationsEnabled INTEGER NOT NULL DEFAULT 1,
            emailNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
            dailyReadingGoal INTEGER NOT NULL DEFAULT 30
          )
        ''');

        // 기존 데이터가 있다면 새 테이블로 마이그레이션 (가능한 필드만)
        final backupExists = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='users_backup'");

        if (backupExists.isNotEmpty) {
          await db.execute('''
            INSERT INTO users (uid, email, displayName, createdAt, updatedAt)
            SELECT 
              COALESCE(userId, 'migrated_' || id),
              email,
              name,
              createdAt,
              COALESCE(createdAt, datetime('now'))
            FROM users_backup
          ''');

          // 백업 테이블 삭제
          await db.execute('DROP TABLE users_backup');
        }
      } catch (e) {
        print('사용자 테이블 업그레이드 중 오류 발생: $e');
      }
    }
  }

  // 최근 책들을 효율적으로 조회하는 메서드들
  static Future<List<Map<String, dynamic>>> getRecentBooks({
    int limit = 20,
    String? status,
  }) async {
    final db = await database;

    String query;
    List<dynamic> args = [];

    if (status != null) {
      // 특정 상태의 책들 조회
      switch (status) {
        case 'reading':
          query = 'SELECT * FROM reading_books_view LIMIT ?';
          break;
        case 'planned':
          query = 'SELECT * FROM planned_books_view LIMIT ?';
          break;
        case 'completed':
          query = 'SELECT * FROM completed_books_view LIMIT ?';
          break;
        default:
          query = 'SELECT * FROM recent_books_view WHERE status = ? LIMIT ?';
          args.add(status);
      }
    } else {
      // 모든 상태의 최근 책들 조회
      query = 'SELECT * FROM recent_books_view LIMIT ?';
    }

    args.add(limit);
    return await db.rawQuery(query, args);
  }

  // 책 업데이트 시 lastReadAt과 updatedAt 자동 갱신
  static Future<void> updateBookActivity(String bookId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'books',
      {
        'lastReadAt': now,
        'updatedAt': now,
      },
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // 책 상태 변경 시 관련 날짜 필드들 자동 업데이트
  static Future<void> updateBookStatus(String bookId, String newStatus) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    Map<String, dynamic> updates = {
      'status': newStatus,
      'updatedAt': now,
    };

    switch (newStatus) {
      case 'reading':
        updates['startedAt'] = now;
        updates['lastReadAt'] = now;
        break;
      case 'completed':
        // 완독 시 현재 페이지를 총 페이지로 설정
        final bookResult = await db.query(
          'books',
          columns: ['totalPages'],
          where: 'bookId = ?',
          whereArgs: [bookId],
          limit: 1,
        );

        if (bookResult.isNotEmpty) {
          final totalPages = bookResult.first['totalPages'] as int;
          updates['currentPage'] = totalPages;
        }

        updates['completedAt'] = now;
        updates['lastReadAt'] = now;
        break;
      case 'planned':
        // planned 상태로 돌아갈 때는 특별한 날짜 업데이트 없음
        break;
    }

    await db.update(
      'books',
      updates,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // 통계를 위한 효율적인 쿼리들
  static Future<Map<String, int>> getBookCountsByStatus() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM books
      GROUP BY status
    ''');

    Map<String, int> counts = {
      'planned': 0,
      'reading': 0,
      'completed': 0,
    };

    for (final row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }

    return counts;
  }

  // 월별 독서 통계
  static Future<List<Map<String, dynamic>>> getMonthlyReadingStats(
      int year) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        strftime('%m', completedAt) as month,
        COUNT(*) as completedBooks,
        SUM(totalPages) as totalPages
      FROM books
      WHERE status = 'completed' 
        AND strftime('%Y', completedAt) = ?
      GROUP BY strftime('%m', completedAt)
      ORDER BY month
    ''', [year.toString()]);
  }
}

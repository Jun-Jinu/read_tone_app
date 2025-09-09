import 'package:dartz/dartz.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';

class ReadingStatsUseCase {
  final BookRepository bookRepository;

  ReadingStatsUseCase(this.bookRepository);

  /// 전체 독서 통계 조회
  Future<Either<Failure, OverallStats>> getOverallStats() async {
    try {
      // 상태별 책 수 조회
      final statusCountsResult = await bookRepository.getBookCountsByStatus();

      return statusCountsResult.fold(
        (failure) => Left(failure),
        (statusCounts) async {
          // 전체 책 목록 조회하여 상세 통계 계산
          final booksResult = await bookRepository.getBooks();

          return booksResult.fold(
            (failure) => Left(failure),
            (books) {
              return Right(_calculateOverallStats(books, statusCounts));
            },
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: '통계 조회 실패: ${e.toString()}'));
    }
  }

  /// 월별 독서 통계 조회
  Future<Either<Failure, List<MonthlyStats>>> getMonthlyStats(int year) async {
    final monthlyStatsResult =
        await bookRepository.getMonthlyReadingStats(year);

    return monthlyStatsResult.fold(
      (failure) => Left(failure),
      (rawStats) {
        final monthlyStats = rawStats.map((stat) {
          return MonthlyStats(
            month: int.parse(stat['month'] as String),
            year: year,
            completedBooks: stat['completedBooks'] as int,
            totalPages: stat['totalPages'] as int,
          );
        }).toList();

        return Right(monthlyStats);
      },
    );
  }

  /// 주간 독서 목표 대비 진행률
  Future<Either<Failure, WeeklyProgress>> getWeeklyProgress() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final booksResult = await bookRepository.getBooks();

    return booksResult.fold(
      (failure) => Left(failure),
      (books) {
        final weeklyStats =
            _calculateWeeklyStats(books, startOfWeek, endOfWeek);
        return Right(weeklyStats);
      },
    );
  }

  /// 독서 습관 분석
  Future<Either<Failure, ReadingHabits>> getReadingHabits() async {
    final booksResult = await bookRepository.getBooks();

    return booksResult.fold(
      (failure) => Left(failure),
      (books) {
        final habits = _analyzeReadingHabits(books);
        return Right(habits);
      },
    );
  }

  /// 장르별 통계
  Future<Either<Failure, List<GenreStats>>> getGenreStats() async {
    final booksResult = await bookRepository.getBooks();

    return booksResult.fold(
      (failure) => Left(failure),
      (books) {
        final genreStats = _calculateGenreStats(books);
        return Right(genreStats);
      },
    );
  }

  /// 즐겨찾기 책들의 통계
  Future<Either<Failure, FavoriteStats>> getFavoriteStats() async {
    final favoriteBooksResult = await bookRepository.getFavoriteBooks();

    return favoriteBooksResult.fold(
      (failure) => Left(failure),
      (favoriteBooks) {
        final stats = _calculateFavoriteStats(favoriteBooks);
        return Right(stats);
      },
    );
  }

  /// 읽기 속도 분석
  Future<Either<Failure, ReadingSpeedAnalysis>>
      getReadingSpeedAnalysis() async {
    final booksResult = await bookRepository.getBooks();

    return booksResult.fold(
      (failure) => Left(failure),
      (books) {
        final analysis = _analyzeReadingSpeed(books);
        return Right(analysis);
      },
    );
  }

  // Private helper methods

  OverallStats _calculateOverallStats(
      List<Book> books, Map<String, int> statusCounts) {
    final completedBooks = books.where((b) => b.isCompleted).toList();
    final readingBooks = books.where((b) => b.isReading).toList();

    final totalPages =
        completedBooks.fold<int>(0, (sum, book) => sum + book.totalPages);
    final currentPageSum =
        readingBooks.fold<int>(0, (sum, book) => sum + book.currentPage);

    final totalReadingMinutes =
        books.fold<int>(0, (sum, book) => sum + book.totalReadingTime);

    final averagePagesPerBook =
        completedBooks.isNotEmpty ? totalPages / completedBooks.length : 0.0;

    final completionRate =
        books.isNotEmpty ? completedBooks.length / books.length : 0.0;

    return OverallStats(
      totalBooks: books.length,
      completedBooks: statusCounts['completed'] ?? 0,
      readingBooks: statusCounts['reading'] ?? 0,
      plannedBooks: statusCounts['planned'] ?? 0,
      totalPagesRead: totalPages + currentPageSum,
      totalReadingTime: Duration(minutes: totalReadingMinutes),
      averagePagesPerBook: averagePagesPerBook,
      completionRate: completionRate,
      favoriteBooks: books.where((b) => b.isFavorite).length,
      highPriorityBooks: books.where((b) => b.priority > 0).length,
    );
  }

  WeeklyProgress _calculateWeeklyStats(
      List<Book> books, DateTime startOfWeek, DateTime endOfWeek) {
    final weeklyBooks = books.where((book) {
      return book.readingSessions.any((session) =>
          session.startTime.isAfter(startOfWeek) &&
          session.startTime.isBefore(endOfWeek));
    }).toList();

    final weeklyPages = weeklyBooks.fold<int>(0, (sum, book) {
      return sum +
          book.readingSessions
              .where((session) =>
                  session.startTime.isAfter(startOfWeek) &&
                  session.startTime.isBefore(endOfWeek))
              .fold<int>(0, (sessSum, session) => sessSum + session.pagesRead);
    });

    final weeklyMinutes = weeklyBooks.fold<int>(0, (sum, book) {
      return sum +
          book.readingSessions
              .where((session) =>
                  session.startTime.isAfter(startOfWeek) &&
                  session.startTime.isBefore(endOfWeek))
              .fold<int>(0,
                  (sessSum, session) => sessSum + session.duration.inMinutes);
    });

    const weeklyGoalPages = 200; // 기본 주간 목표 (설정 가능하게 개선 가능)
    const weeklyGoalMinutes = 420; // 하루 1시간씩

    return WeeklyProgress(
      startDate: startOfWeek,
      endDate: endOfWeek,
      pagesRead: weeklyPages,
      readingTime: Duration(minutes: weeklyMinutes),
      goalPages: weeklyGoalPages,
      goalTime: const Duration(minutes: weeklyGoalMinutes),
      booksStarted: weeklyBooks
          .where((b) =>
              b.startedAt != null &&
              b.startedAt!.isAfter(startOfWeek) &&
              b.startedAt!.isBefore(endOfWeek))
          .length,
      booksCompleted: weeklyBooks
          .where((b) =>
              b.completedAt != null &&
              b.completedAt!.isAfter(startOfWeek) &&
              b.completedAt!.isBefore(endOfWeek))
          .length,
    );
  }

  ReadingHabits _analyzeReadingHabits(List<Book> books) {
    final allSessions = books.expand((book) => book.readingSessions).toList();

    if (allSessions.isEmpty) {
      return ReadingHabits.empty();
    }

    // 시간대별 독서 패턴 분석
    final hourlyStats = <int, int>{};
    for (final session in allSessions) {
      final hour = session.startTime.hour;
      hourlyStats[hour] = (hourlyStats[hour] ?? 0) + 1;
    }

    final mostActiveHour =
        hourlyStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // 요일별 독서 패턴
    final weekdayStats = <int, int>{};
    for (final session in allSessions) {
      final weekday = session.startTime.weekday;
      weekdayStats[weekday] = (weekdayStats[weekday] ?? 0) + 1;
    }

    final mostActiveDay =
        weekdayStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // 평균 세션 길이
    final averageSessionLength = allSessions.isNotEmpty
        ? allSessions.fold<int>(
                0, (sum, session) => sum + session.duration.inMinutes) /
            allSessions.length
        : 0.0;

    // 연속 독서일
    final readingDates = allSessions
        .map((s) =>
            DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList();
    readingDates.sort();

    int currentStreak = 0;
    int longestStreak = 0;

    if (readingDates.isNotEmpty) {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      // 현재 연속일 계산
      if (readingDates.contains(todayDate) ||
          readingDates.contains(yesterdayDate)) {
        DateTime checkDate =
            readingDates.contains(todayDate) ? todayDate : yesterdayDate;
        while (readingDates.contains(checkDate)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        }
      }

      // 최장 연속일 계산
      int tempStreak = 1;
      for (int i = 1; i < readingDates.length; i++) {
        if (readingDates[i].difference(readingDates[i - 1]).inDays == 1) {
          tempStreak++;
        } else {
          longestStreak =
              longestStreak > tempStreak ? longestStreak : tempStreak;
          tempStreak = 1;
        }
      }
      longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    }

    return ReadingHabits(
      totalReadingDays: readingDates.length,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageSessionLength: Duration(minutes: averageSessionLength.round()),
      mostActiveHour: mostActiveHour,
      mostActiveDay: mostActiveDay,
      totalSessions: allSessions.length,
    );
  }

  List<GenreStats> _calculateGenreStats(List<Book> books) {
    // 간단한 장르 분류 (실제로는 책 메타데이터에서 가져와야 함)
    final genreMap = <String, GenreStats>{};

    for (final book in books) {
      // 임시로 title 키워드로 장르 추정 (실제로는 proper 장르 필드 필요)
      String genre = _inferGenreFromTitle(book.title);

      if (genreMap.containsKey(genre)) {
        final existing = genreMap[genre]!;
        genreMap[genre] = GenreStats(
          genre: genre,
          totalBooks: existing.totalBooks + 1,
          completedBooks: existing.completedBooks + (book.isCompleted ? 1 : 0),
          totalPages: existing.totalPages + book.totalPages,
          averageRating: existing.averageRating, // 실제로는 평점 데이터 필요
        );
      } else {
        genreMap[genre] = GenreStats(
          genre: genre,
          totalBooks: 1,
          completedBooks: book.isCompleted ? 1 : 0,
          totalPages: book.totalPages,
          averageRating: 0.0,
        );
      }
    }

    return genreMap.values.toList()
      ..sort((a, b) => b.totalBooks.compareTo(a.totalBooks));
  }

  String _inferGenreFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('소설') || lowerTitle.contains('novel')) return '소설';
    if (lowerTitle.contains('경영') || lowerTitle.contains('비즈니스'))
      return '경영/비즈니스';
    if (lowerTitle.contains('자기계발') || lowerTitle.contains('성공')) return '자기계발';
    if (lowerTitle.contains('역사')) return '역사';
    if (lowerTitle.contains('과학') || lowerTitle.contains('기술')) return '과학/기술';
    if (lowerTitle.contains('철학')) return '철학';
    if (lowerTitle.contains('예술') || lowerTitle.contains('문화')) return '예술/문화';
    return '기타';
  }

  FavoriteStats _calculateFavoriteStats(List<Book> favoriteBooks) {
    return FavoriteStats(
      totalFavorites: favoriteBooks.length,
      completedFavorites: favoriteBooks.where((b) => b.isCompleted).length,
      averagePages: favoriteBooks.isNotEmpty
          ? favoriteBooks.fold<int>(0, (sum, book) => sum + book.totalPages) /
              favoriteBooks.length
          : 0.0,
      totalReadingTime: Duration(
          minutes: favoriteBooks.fold<int>(
              0, (sum, book) => sum + book.totalReadingTime)),
    );
  }

  ReadingSpeedAnalysis _analyzeReadingSpeed(List<Book> books) {
    final allSessions = books
        .expand((book) => book.readingSessions)
        .where((s) => s.duration.inMinutes > 0)
        .toList();

    if (allSessions.isEmpty) {
      return ReadingSpeedAnalysis.empty();
    }

    final speeds = allSessions.map((s) => s.readingSpeed).toList();
    speeds.sort();

    final averageSpeed =
        speeds.fold<double>(0, (sum, speed) => sum + speed) / speeds.length;
    final medianSpeed = speeds[speeds.length ~/ 2];
    final maxSpeed = speeds.last;
    final minSpeed = speeds.first;

    return ReadingSpeedAnalysis(
      averageSpeed: averageSpeed,
      medianSpeed: medianSpeed,
      maxSpeed: maxSpeed,
      minSpeed: minSpeed,
      totalSessions: allSessions.length,
    );
  }
}

// Stats classes
class OverallStats {
  final int totalBooks;
  final int completedBooks;
  final int readingBooks;
  final int plannedBooks;
  final int totalPagesRead;
  final Duration totalReadingTime;
  final double averagePagesPerBook;
  final double completionRate;
  final int favoriteBooks;
  final int highPriorityBooks;

  const OverallStats({
    required this.totalBooks,
    required this.completedBooks,
    required this.readingBooks,
    required this.plannedBooks,
    required this.totalPagesRead,
    required this.totalReadingTime,
    required this.averagePagesPerBook,
    required this.completionRate,
    required this.favoriteBooks,
    required this.highPriorityBooks,
  });
}

class MonthlyStats {
  final int month;
  final int year;
  final int completedBooks;
  final int totalPages;

  const MonthlyStats({
    required this.month,
    required this.year,
    required this.completedBooks,
    required this.totalPages,
  });
}

class WeeklyProgress {
  final DateTime startDate;
  final DateTime endDate;
  final int pagesRead;
  final Duration readingTime;
  final int goalPages;
  final Duration goalTime;
  final int booksStarted;
  final int booksCompleted;

  const WeeklyProgress({
    required this.startDate,
    required this.endDate,
    required this.pagesRead,
    required this.readingTime,
    required this.goalPages,
    required this.goalTime,
    required this.booksStarted,
    required this.booksCompleted,
  });

  double get pagesProgress => goalPages > 0 ? pagesRead / goalPages : 0.0;
  double get timeProgress =>
      goalTime.inMinutes > 0 ? readingTime.inMinutes / goalTime.inMinutes : 0.0;
}

class ReadingHabits {
  final int totalReadingDays;
  final int currentStreak;
  final int longestStreak;
  final Duration averageSessionLength;
  final int mostActiveHour;
  final int mostActiveDay;
  final int totalSessions;

  const ReadingHabits({
    required this.totalReadingDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageSessionLength,
    required this.mostActiveHour,
    required this.mostActiveDay,
    required this.totalSessions,
  });

  factory ReadingHabits.empty() {
    return const ReadingHabits(
      totalReadingDays: 0,
      currentStreak: 0,
      longestStreak: 0,
      averageSessionLength: Duration.zero,
      mostActiveHour: 0,
      mostActiveDay: 1,
      totalSessions: 0,
    );
  }
}

class GenreStats {
  final String genre;
  final int totalBooks;
  final int completedBooks;
  final int totalPages;
  final double averageRating;

  const GenreStats({
    required this.genre,
    required this.totalBooks,
    required this.completedBooks,
    required this.totalPages,
    required this.averageRating,
  });
}

class FavoriteStats {
  final int totalFavorites;
  final int completedFavorites;
  final double averagePages;
  final Duration totalReadingTime;

  const FavoriteStats({
    required this.totalFavorites,
    required this.completedFavorites,
    required this.averagePages,
    required this.totalReadingTime,
  });
}

class ReadingSpeedAnalysis {
  final double averageSpeed;
  final double medianSpeed;
  final double maxSpeed;
  final double minSpeed;
  final int totalSessions;

  const ReadingSpeedAnalysis({
    required this.averageSpeed,
    required this.medianSpeed,
    required this.maxSpeed,
    required this.minSpeed,
    required this.totalSessions,
  });

  factory ReadingSpeedAnalysis.empty() {
    return const ReadingSpeedAnalysis(
      averageSpeed: 0.0,
      medianSpeed: 0.0,
      maxSpeed: 0.0,
      minSpeed: 0.0,
      totalSessions: 0,
    );
  }
}

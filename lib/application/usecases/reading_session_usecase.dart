import 'package:dartz/dartz.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';

class ReadingSessionUseCase {
  final BookRepository bookRepository;

  ReadingSessionUseCase(this.bookRepository);

  /// 새로운 독서 세션 시작
  Future<Either<Failure, ReadingSession>> startSession({
    required String bookId,
    required int startPage,
    String? memo,
  }) async {
    final now = DateTime.now();

    // 미완료 세션이 있는지 확인
    final activeSessionResult = await getActiveSession(bookId);
    return activeSessionResult.fold(
      (failure) async {
        // 활성 세션이 없으면 새로 시작
        final session = ReadingSession(
          id: 'session_${now.millisecondsSinceEpoch}',
          startTime: now,
          endTime: now, // 임시, 종료시 업데이트
          startPage: startPage,
          endPage: startPage, // 임시, 종료시 업데이트
          memo: memo,
          createdAt: now,
        );

        // TODO: 활성 세션을 별도 테이블에 저장하는 로직 추가
        return Right(session);
      },
      (activeSession) {
        // 이미 활성 세션이 있으면 에러
        return Left(ValidationFailure(message: '이미 진행 중인 독서 세션이 있습니다.'));
      },
    );
  }

  /// 독서 세션 종료
  Future<Either<Failure, void>> endSession({
    required String bookId,
    required String sessionId,
    required int endPage,
    String? memo,
  }) async {
    final bookResult = await bookRepository.getBook(bookId);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final now = DateTime.now();

        // 기존 세션을 찾아서 업데이트
        final sessions = book.readingSessions.toList();
        final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);

        if (sessionIndex == -1) {
          return Left(ValidationFailure(message: '세션을 찾을 수 없습니다.'));
        }

        final oldSession = sessions[sessionIndex];
        final updatedSession = ReadingSession(
          id: oldSession.id,
          startTime: oldSession.startTime,
          endTime: now,
          startPage: oldSession.startPage,
          endPage: endPage,
          memo: memo ?? oldSession.memo,
          createdAt: oldSession.createdAt,
        );

        sessions[sessionIndex] = updatedSession;

        // 책 정보 업데이트 (currentPage, lastReadAt 등)
        final updatedBook = book.copyWith(
          currentPage: endPage,
          readingSessions: sessions,
          lastReadAt: now,
          updatedAt: now,
        );

        final updateResult = await bookRepository.updateBook(updatedBook);

        // 독서 활동 추적 업데이트
        if (updateResult.isRight()) {
          await bookRepository.updateBookActivity(bookId);
        }

        return updateResult;
      },
    );
  }

  /// 현재 활성 독서 세션 조회
  Future<Either<Failure, ReadingSession>> getActiveSession(
      String bookId) async {
    final bookResult = await bookRepository.getBook(bookId);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) {
        // 아직 종료되지 않은 세션 찾기 (startTime == endTime인 경우)
        try {
          final activeSession = book.readingSessions.firstWhere(
            (session) => session.startTime == session.endTime,
          );
          return Right(activeSession);
        } catch (e) {
          return Left(ValidationFailure(message: '활성 세션이 없습니다.'));
        }
      },
    );
  }

  /// 책의 모든 독서 세션 조회
  Future<Either<Failure, List<ReadingSession>>> getBookSessions(
      String bookId) async {
    final bookResult = await bookRepository.getBook(bookId);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) => Right(book.readingSessions),
    );
  }

  /// 특정 기간의 독서 세션 조회
  Future<Either<Failure, List<ReadingSession>>> getSessionsByDateRange({
    required String bookId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sessionsResult = await getBookSessions(bookId);
    return sessionsResult.fold(
      (failure) => Left(failure),
      (sessions) {
        final filteredSessions = sessions.where((session) {
          return session.startTime.isAfter(startDate) &&
              session.startTime.isBefore(endDate);
        }).toList();
        return Right(filteredSessions);
      },
    );
  }

  /// 독서 세션 통계 계산
  Future<Either<Failure, ReadingSessionStats>> getSessionStats(
      String bookId) async {
    final sessionsResult = await getBookSessions(bookId);
    return sessionsResult.fold(
      (failure) => Left(failure),
      (sessions) {
        if (sessions.isEmpty) {
          return Right(ReadingSessionStats.empty());
        }

        final completedSessions =
            sessions.where((s) => s.duration.inMinutes > 0).toList();

        final totalMinutes = completedSessions.fold<int>(
          0,
          (sum, session) => sum + session.duration.inMinutes,
        );

        final totalPages = completedSessions.fold<int>(
          0,
          (sum, session) => sum + session.pagesRead,
        );

        final averageSpeed = totalMinutes > 0 ? totalPages / totalMinutes : 0.0;
        final averageSessionDuration = completedSessions.isNotEmpty
            ? totalMinutes / completedSessions.length
            : 0.0;

        return Right(ReadingSessionStats(
          totalSessions: completedSessions.length,
          totalReadingTime: Duration(minutes: totalMinutes),
          totalPagesRead: totalPages,
          averageReadingSpeed: averageSpeed, // 분당 페이지 수
          averageSessionDuration:
              Duration(minutes: averageSessionDuration.round()),
          lastSessionDate: completedSessions.isNotEmpty
              ? completedSessions.last.endTime
              : null,
        ));
      },
    );
  }

  /// 간단한 독서 기록 추가 (세션 시작/종료를 한번에)
  Future<Either<Failure, void>> addQuickSession({
    required String bookId,
    required int startPage,
    required int endPage,
    required Duration duration,
    String? memo,
  }) async {
    final bookResult = await bookRepository.getBook(bookId);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final now = DateTime.now();
        final startTime = now.subtract(duration);

        final session = ReadingSession(
          id: 'session_${now.millisecondsSinceEpoch}',
          startTime: startTime,
          endTime: now,
          startPage: startPage,
          endPage: endPage,
          memo: memo,
          createdAt: now,
        );

        final updatedBook = book.copyWith(
          currentPage: endPage,
          readingSessions: [...book.readingSessions, session],
          lastReadAt: now,
          updatedAt: now,
        );

        final updateResult = await bookRepository.updateBook(updatedBook);

        if (updateResult.isRight()) {
          await bookRepository.updateBookActivity(bookId);
        }

        return updateResult;
      },
    );
  }
}

/// 독서 세션 통계 클래스
class ReadingSessionStats {
  final int totalSessions;
  final Duration totalReadingTime;
  final int totalPagesRead;
  final double averageReadingSpeed; // 분당 페이지 수
  final Duration averageSessionDuration;
  final DateTime? lastSessionDate;

  const ReadingSessionStats({
    required this.totalSessions,
    required this.totalReadingTime,
    required this.totalPagesRead,
    required this.averageReadingSpeed,
    required this.averageSessionDuration,
    this.lastSessionDate,
  });

  factory ReadingSessionStats.empty() {
    return const ReadingSessionStats(
      totalSessions: 0,
      totalReadingTime: Duration.zero,
      totalPagesRead: 0,
      averageReadingSpeed: 0.0,
      averageSessionDuration: Duration.zero,
      lastSessionDate: null,
    );
  }

  /// 하루 평균 독서 시간 (분)
  double get averageDailyReadingMinutes {
    if (lastSessionDate == null || totalSessions == 0) return 0.0;

    final daysSinceStart = DateTime.now().difference(lastSessionDate!).inDays;
    return daysSinceStart > 0
        ? totalReadingTime.inMinutes / daysSinceStart
        : 0.0;
  }

  /// 읽기 속도 레벨 (초급/중급/고급)
  String get readingSpeedLevel {
    if (averageReadingSpeed >= 2.0) return '고급';
    if (averageReadingSpeed >= 1.0) return '중급';
    return '초급';
  }
}

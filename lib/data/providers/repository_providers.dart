import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_tone_app/data/datasources/book_remote_data_source.dart';
import 'package:read_tone_app/data/datasources/book_remote_data_source_impl.dart';
import 'package:read_tone_app/data/repositories/book_repository_impl.dart';
import 'package:read_tone_app/data/providers/database_providers.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';
import 'package:read_tone_app/application/usecases/get_recent_books_usecase.dart';
import 'package:read_tone_app/application/usecases/book_usecases.dart';
import 'package:read_tone_app/application/usecases/reading_session_usecase.dart';
import 'package:read_tone_app/application/usecases/reading_stats_usecase.dart';

// 리모트 데이터소스 프로바이더
final bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((ref) {
  // Mock 구현체 사용 (실제 API 구현시 교체)
  return BookRemoteDataSourceImpl();
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  final localDataSource = ref.watch(bookLocalDataSourceProvider);
  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// UseCase 프로바이더들
final getRecentBooksUseCaseProvider = Provider((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return GetRecentBooksUseCase(bookRepository);
});

final bookUseCasesProvider = Provider<BookUseCases>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return BookUseCasesImpl(bookRepository);
});

final readingSessionUseCaseProvider = Provider((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return ReadingSessionUseCase(bookRepository);
});

final readingStatsUseCaseProvider = Provider((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return ReadingStatsUseCase(bookRepository);
});

// 개별 UseCase 프로바이더들 (편의성을 위해)
final startReadingUseCaseProvider = Provider((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return (String bookId) => bookUseCases.startReading(bookId);
});

final completeBookUseCaseProvider = Provider((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return (String bookId) => bookUseCases.completeBook(bookId);
});

final updateReadingProgressUseCaseProvider = Provider((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return (String bookId, int currentPage) =>
      bookUseCases.updateReadingProgress(bookId, currentPage);
});

final toggleFavoriteUseCaseProvider = Provider((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return (String bookId) => bookUseCases.toggleFavorite(bookId);
});

final updatePriorityUseCaseProvider = Provider((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return (String bookId, int priority) =>
      bookUseCases.updatePriority(bookId, priority);
});

// 독서 세션 관련 UseCase 프로바이더들
final startSessionUseCaseProvider = Provider((ref) {
  final sessionUseCase = ref.watch(readingSessionUseCaseProvider);
  return ({required String bookId, required int startPage, String? memo}) =>
      sessionUseCase.startSession(
          bookId: bookId, startPage: startPage, memo: memo);
});

final endSessionUseCaseProvider = Provider((ref) {
  final sessionUseCase = ref.watch(readingSessionUseCaseProvider);
  return (
          {required String bookId,
          required String sessionId,
          required int endPage,
          String? memo}) =>
      sessionUseCase.endSession(
          bookId: bookId, sessionId: sessionId, endPage: endPage, memo: memo);
});

final addQuickSessionUseCaseProvider = Provider((ref) {
  final sessionUseCase = ref.watch(readingSessionUseCaseProvider);
  return ({
    required String bookId,
    required int startPage,
    required int endPage,
    required Duration duration,
    String? memo,
  }) =>
      sessionUseCase.addQuickSession(
        bookId: bookId,
        startPage: startPage,
        endPage: endPage,
        duration: duration,
        memo: memo,
      );
});

// 통계 관련 UseCase 프로바이더들
final getOverallStatsUseCaseProvider = Provider((ref) {
  final statsUseCase = ref.watch(readingStatsUseCaseProvider);
  return () => statsUseCase.getOverallStats();
});

final getMonthlyStatsUseCaseProvider = Provider((ref) {
  final statsUseCase = ref.watch(readingStatsUseCaseProvider);
  return (int year) => statsUseCase.getMonthlyStats(year);
});

final getWeeklyProgressUseCaseProvider = Provider((ref) {
  final statsUseCase = ref.watch(readingStatsUseCaseProvider);
  return () => statsUseCase.getWeeklyProgress();
});

final getReadingHabitsUseCaseProvider = Provider((ref) {
  final statsUseCase = ref.watch(readingStatsUseCaseProvider);
  return () => statsUseCase.getReadingHabits();
});

final getSessionStatsUseCaseProvider = Provider((ref) {
  final sessionUseCase = ref.watch(readingSessionUseCaseProvider);
  return (String bookId) => sessionUseCase.getSessionStats(bookId);
});

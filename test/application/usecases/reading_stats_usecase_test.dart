import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:read_tone_app/application/usecases/reading_stats_usecase.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockBookRepository mockBookRepository;
  late ReadingStatsUseCase usecase;

  setUp(() {
    mockBookRepository = MockBookRepository();
    usecase = ReadingStatsUseCase(mockBookRepository);
  });

  group('ReadingStatsUseCase.getOverallStats', () {
    test('정상적으로 OverallStats를 계산한다', () async {
      // arrange
      when(() => mockBookRepository.getBookCountsByStatus()).thenAnswer(
        (_) async => Right({'planned': 1, 'reading': 1, 'completed': 1}),
      );

      final books = [
        Book(
          id: '1',
          title: '완독',
          author: 'a',
          coverImageUrl: '',
          totalPages: 100,
          currentPage: 100,
          status: BookStatus.completed,
          createdAt: DateTime(2024),
          completedAt: DateTime(2024),
          updatedAt: DateTime(2024),
          readingSessions: const [],
          notes: const [],
        ),
        Book(
          id: '2',
          title: '읽는중',
          author: 'a',
          coverImageUrl: '',
          totalPages: 200,
          currentPage: 50,
          status: BookStatus.reading,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          readingSessions: const [],
          notes: const [],
        ),
        Book(
          id: '3',
          title: '계획',
          author: 'a',
          coverImageUrl: '',
          totalPages: 150,
          currentPage: 0,
          status: BookStatus.planned,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          readingSessions: const [],
          notes: const [],
        ),
      ];

      when(
        () => mockBookRepository.getBooks(),
      ).thenAnswer((_) async => Right(books));

      // act
      final result = await usecase.getOverallStats();

      // assert
      expect(result.isRight(), true);
      result.fold((_) {}, (stats) {
        expect(stats.totalBooks, 3);
        expect(stats.completedBooks, 1);
        expect(stats.readingBooks, 1);
        expect(stats.plannedBooks, 1);
        expect(stats.totalPagesRead, 150); // completed 100 + reading current 50
      });
    });

    test('리포지토리 에러 시 Failure 반환', () async {
      when(
        () => mockBookRepository.getBookCountsByStatus(),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'err')));

      final result = await usecase.getOverallStats();
      expect(result.isLeft(), true);
    });
  });
}

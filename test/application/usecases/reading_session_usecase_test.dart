import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:read_tone_app/application/usecases/reading_session_usecase.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockBookRepository mockBookRepository;
  late ReadingSessionUseCase usecase;

  setUpAll(() {
    registerFallbackValue(FakeBook());
  });

  setUp(() {
    mockBookRepository = MockBookRepository();
    usecase = ReadingSessionUseCase(mockBookRepository);
  });

  group('ReadingSessionUseCase.startSession', () {
    test('활성 세션이 없으면 새 세션을 시작하여 Right를 반환', () async {
      // arrange
      when(
        () => mockBookRepository.getBook(any()),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'no active')));

      // act
      final result = await usecase.startSession(bookId: 'b1', startPage: 1);

      // assert
      expect(result.isRight(), true);
    });

    test('이미 활성 세션이 있으면 ValidationFailure를 반환', () async {
      // arrange
      final book = Book(
        id: 'b1',
        title: 't',
        author: 'a',
        coverImageUrl: '',
        totalPages: 100,
        currentPage: 10,
        status: BookStatus.reading,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        readingSessions: [
          ReadingSession(
            id: 's1',
            startTime: DateTime(2024),
            endTime: DateTime(2024),
            startPage: 1,
            endPage: 1,
            createdAt: DateTime(2024),
          ),
        ],
        notes: const [],
      );

      when(
        () => mockBookRepository.getBook(any()),
      ).thenAnswer((_) async => Right(book));

      // act
      final result = await usecase.startSession(bookId: 'b1', startPage: 2);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (_) => fail('should not be right'),
      );
    });
  });

  group('ReadingSessionUseCase.endSession', () {
    test('세션 종료 후 책 업데이트와 활동 업데이트가 호출된다', () async {
      // arrange
      final session = ReadingSession(
        id: 's1',
        startTime: DateTime(2024, 1, 1, 10),
        endTime: DateTime(2024, 1, 1, 10), // active
        startPage: 1,
        endPage: 1,
        createdAt: DateTime(2024, 1, 1, 10),
      );

      final book = Book(
        id: 'b1',
        title: 't',
        author: 'a',
        coverImageUrl: '',
        totalPages: 100,
        currentPage: 1,
        status: BookStatus.reading,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        readingSessions: [session],
        notes: const [],
      );

      when(
        () => mockBookRepository.getBook('b1'),
      ).thenAnswer((_) async => Right(book));
      when(
        () => mockBookRepository.updateBook(any()),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockBookRepository.updateBookActivity('b1'),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase.endSession(
        bookId: 'b1',
        sessionId: 's1',
        endPage: 10,
      );

      // assert
      expect(result.isRight(), true);
      verify(() => mockBookRepository.updateBook(any())).called(1);
      verify(() => mockBookRepository.updateBookActivity('b1')).called(1);
    });
  });
}

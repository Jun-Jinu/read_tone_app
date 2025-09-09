import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:read_tone_app/application/usecases/get_recent_books_usecase.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockBookRepository mockBookRepository;
  late GetRecentBooksUseCase usecase;

  setUpAll(() {
    registerFallbackValue(BookStatus.planned);
  });

  setUp(() {
    mockBookRepository = MockBookRepository();
    usecase = GetRecentBooksUseCase(mockBookRepository);
  });

  group('GetRecentBooksUseCase', () {
    test('call()은 최근 책 목록을 반환한다', () async {
      // arrange
      final books = [
        Book(
          id: '1',
          title: 'A',
          author: 'author',
          coverImageUrl: '',
          totalPages: 100,
          currentPage: 0,
          status: BookStatus.planned,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          readingSessions: const [],
          notes: const [],
        ),
      ];
      when(
        () => mockBookRepository.getRecentBooks(limit: any(named: 'limit')),
      ).thenAnswer((_) async => Right(books));

      // act
      final result = await usecase(limit: 10);

      // assert
      expect(result.isRight(), true);
      result.fold((_) {}, (data) {
        expect(data, books);
      });
      verify(() => mockBookRepository.getRecentBooks(limit: 10)).called(1);
      verifyNoMoreInteractions(mockBookRepository);
    });

    test('getByStatus()는 상태별 최근 책 목록을 반환한다', () async {
      // arrange
      when(
        () => mockBookRepository.getRecentBooksByStatus(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(const []));

      // act
      final result = await usecase.getByStatus(status: BookStatus.reading);

      // assert
      expect(result.isRight(), true);
      verify(
        () => mockBookRepository.getRecentBooksByStatus(
          status: BookStatus.reading,
          limit: 20,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockBookRepository);
    });

    test('getFavoriteBooks()는 즐겨찾기 책 목록을 반환한다', () async {
      // arrange
      when(
        () => mockBookRepository.getFavoriteBooks(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(const []));

      // act
      final result = await usecase.getFavoriteBooks();

      // assert
      expect(result.isRight(), true);
      verify(
        () => mockBookRepository.getFavoriteBooks(status: null, limit: 20),
      ).called(1);
      verifyNoMoreInteractions(mockBookRepository);
    });

    test('getHighPriorityBooks()는 우선순위 책 목록을 반환한다', () async {
      // arrange
      when(
        () => mockBookRepository.getHighPriorityBooks(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(const []));

      // act
      final result = await usecase.getHighPriorityBooks();

      // assert
      expect(result.isRight(), true);
      verify(
        () => mockBookRepository.getHighPriorityBooks(status: null, limit: 20),
      ).called(1);
      verifyNoMoreInteractions(mockBookRepository);
    });

    test('리포지토리 오류 시 Failure를 반환한다', () async {
      // arrange
      when(
        () => mockBookRepository.getRecentBooks(limit: any(named: 'limit')),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'error')));

      // act
      final result = await usecase();

      // assert
      expect(result.isLeft(), true);
    });
  });
}

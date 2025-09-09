import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:read_tone_app/data/repositories/book_repository_impl.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/core/error/failures.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBookRemoteDataSource mockRemote;
  late MockBookLocalDataSource mockLocal;
  late BookRepositoryImpl repository;

  setUp(() {
    mockRemote = MockBookRemoteDataSource();
    mockLocal = MockBookLocalDataSource();
    repository = BookRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  Book _book({String id = 'b1'}) => Book(
    id: id,
    title: 't',
    author: 'a',
    coverImageUrl: '',
    totalPages: 100,
    currentPage: 0,
    status: BookStatus.planned,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    readingSessions: const [],
    notes: const [],
  );

  group('getBooks', () {
    test('원격 성공 시 캐시 저장 후 리스트 반환', () async {
      when(() => mockRemote.getBooks()).thenAnswer((_) async => [_book()]);
      when(() => mockLocal.cacheBooks(any())).thenAnswer((_) async {});

      final result = await repository.getBooks();

      expect(result.isRight(), true);
      verify(() => mockRemote.getBooks()).called(1);
      verify(() => mockLocal.cacheBooks(any())).called(1);
      verifyNoMoreInteractions(mockRemote);
      verifyNoMoreInteractions(mockLocal);
    });

    test('원격 실패, 로컬 캐시가 있으면 캐시 반환', () async {
      when(() => mockRemote.getBooks()).thenThrow(Exception('network'));
      when(() => mockLocal.getLastBooks()).thenAnswer((_) async => [_book()]);

      final result = await repository.getBooks();
      expect(result.isRight(), true);
      verify(() => mockLocal.getLastBooks()).called(1);
    });

    test('원격 실패, 로컬 캐시 비어있으면 Failure 반환', () async {
      when(() => mockRemote.getBooks()).thenThrow(Exception('network'));
      when(() => mockLocal.getLastBooks()).thenAnswer((_) async => []);

      final result = await repository.getBooks();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (_) => fail('should fail'),
      );
    });
  });

  group('getBook', () {
    test('원격 성공 시 캐시 저장 후 반환', () async {
      final b = _book(id: 'x');
      when(() => mockRemote.getBook('x')).thenAnswer((_) async => b);
      when(() => mockLocal.cacheBook(b)).thenAnswer((_) async {});

      final result = await repository.getBook('x');
      expect(result.isRight(), true);
      verify(() => mockLocal.cacheBook(b)).called(1);
    });

    test('원격 예외 시 Failure 반환', () async {
      when(() => mockRemote.getBook('x')).thenThrow(Exception('404'));
      final result = await repository.getBook('x');
      expect(result.isLeft(), true);
    });
  });

  group('add/update/delete/search', () {
    test('addBook 성공 시 캐시 저장', () async {
      final b = _book();
      when(() => mockRemote.addBook(b)).thenAnswer((_) async => b);
      when(() => mockLocal.cacheBook(b)).thenAnswer((_) async {});
      final result = await repository.addBook(b);
      expect(result.isRight(), true);
      verify(() => mockLocal.cacheBook(b)).called(1);
    });

    test('updateBook 성공 시 캐시 저장', () async {
      final b = _book();
      when(() => mockRemote.updateBook(b)).thenAnswer((_) async {});
      when(() => mockLocal.cacheBook(b)).thenAnswer((_) async {});
      final result = await repository.updateBook(b);
      expect(result, const Right(null));
      verify(() => mockLocal.cacheBook(b)).called(1);
    });

    test('deleteBook 성공 시 로컬도 삭제', () async {
      when(() => mockRemote.deleteBook('x')).thenAnswer((_) async {});
      when(() => mockLocal.deleteBook('x')).thenAnswer((_) async {});
      final result = await repository.deleteBook('x');
      expect(result, const Right(null));
      verify(() => mockLocal.deleteBook('x')).called(1);
    });

    test('searchBooks 성공 시 Right 반환', () async {
      when(
        () => mockRemote.searchBooks('q'),
      ).thenAnswer((_) async => [_book()]);
      final result = await repository.searchBooks('q');
      expect(result.isRight(), true);
    });
  });
}

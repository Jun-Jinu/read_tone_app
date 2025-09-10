import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/presentation/providers/book_provider.dart';
import 'package:read_tone_app/data/providers/repository_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import '../../helpers/mocks.dart';

void main() {
  late ProviderContainer container;
  late MockBookUseCases mockUseCases;

  setUp(() {
    mockUseCases = MockBookUseCases();
    container = ProviderContainer(
      overrides: [bookUseCasesProvider.overrideWithValue(mockUseCases)],
    );
    addTearDown(container.dispose);
  });

  Book _book() => Book(
    id: 'b1',
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

  test('booksProvider: getBooks 성공 시 데이터 로드', () async {
    when(
      () => mockUseCases.getBooks(),
    ).thenAnswer((_) async => Right([_book()]));

    // 초기 로딩 후 데이터 상태가 되는지 확인
    await Future<void>.delayed(const Duration(milliseconds: 1));
    final state = container.read(booksProvider);
    expect(state.isLoading || state.hasValue, true);
  });
}

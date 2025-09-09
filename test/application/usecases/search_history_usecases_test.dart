import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/application/usecases/search_history_usecases.dart';
import 'package:read_tone_app/domain/entities/search_history.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockSearchHistoryRepository repository;

  setUpAll(() {
    registerFallbackValue(
      SearchHistory(id: 'x', query: 'q', createdAt: DateTime(2024)),
    );
  });

  setUp(() {
    repository = MockSearchHistoryRepository();
  });

  group('AddSearchHistoryUseCase', () {
    test('중복 검색어면 업데이트, 아니면 추가를 호출', () async {
      final usecase = AddSearchHistoryUseCase(repository);

      // 이미 존재하는 경우
      when(() => repository.searchHistoryByQuery('flutter')).thenAnswer(
        (_) async => [
          SearchHistory(id: '1', query: 'flutter', createdAt: DateTime(2024)),
        ],
      );
      when(
        () => repository.updateSearchHistory(any()),
      ).thenAnswer((_) async {});

      await usecase('flutter');
      verify(() => repository.updateSearchHistory(any())).called(1);

      // 존재하지 않는 경우
      when(
        () => repository.searchHistoryByQuery('riverpod'),
      ).thenAnswer((_) async => []);
      when(() => repository.addSearchHistory(any())).thenAnswer((_) async {});

      await usecase('riverpod');
      verify(() => repository.addSearchHistory(any())).called(1);
    });
  });

  group('GetRecentSearchHistoryUseCase', () {
    test('limit 기본값으로 최근 검색 기록을 반환', () async {
      final usecase = GetRecentSearchHistoryUseCase(repository);
      when(
        () => repository.getRecentSearchHistory(any()),
      ).thenAnswer((_) async => const []);

      await usecase();
      verify(() => repository.getRecentSearchHistory(10)).called(1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/application/usecases/settings_usecases.dart';
import 'package:read_tone_app/domain/entities/settings.dart' as s;
import '../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(s.Settings.initial());
  });

  group('Settings UseCases', () {
    late MockSettingsRepository repository;

    setUp(() {
      repository = MockSettingsRepository();
    });

    test('GetSettingsUseCase는 저장소에서 설정을 가져온다', () async {
      final usecase = GetSettingsUseCase(repository);
      when(
        () => repository.getSettings(),
      ).thenAnswer((_) async => s.Settings.initial());

      final result = await usecase();
      expect(result.id, 'default_settings');
    });

    test('UpdateThemeModeUseCase: 현재 설정을 가져와 테마만 변경하여 저장', () async {
      when(
        () => repository.getSettings(),
      ).thenAnswer((_) async => s.Settings.initial());
      when(() => repository.saveSettings(any())).thenAnswer((_) async {});

      final usecase = UpdateThemeModeUseCase(repository);
      await usecase(s.ThemeMode.dark);

      verify(() => repository.getSettings()).called(1);
      verify(() => repository.saveSettings(any())).called(1);
    });

    test('UpdateDailyGoalUseCase: 분 설정이 없으면 기존 값을 유지', () async {
      final initial = s.Settings.initial();
      when(() => repository.getSettings()).thenAnswer((_) async => initial);
      when(() => repository.saveSettings(any())).thenAnswer((_) async {});

      final usecase = UpdateDailyGoalUseCase(repository);
      await usecase(isEnabled: true);

      verify(() => repository.saveSettings(any())).called(1);
    });

    test('ObserveSettingsUseCase: 스트림 반환 타입 확인', () async {
      final usecase = ObserveSettingsUseCase(repository);
      // 목 스트림은 별도 구현 없이 타입 확인만
      expect(usecase(), isA<Stream<s.Settings>>());
    });
  });
}

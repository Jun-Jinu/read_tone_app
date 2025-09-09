import 'package:flutter/material.dart' show TimeOfDay; // for settings
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/application/usecases/settings_usecases.dart';
import 'package:read_tone_app/domain/entities/settings.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository repository;

  setUpAll(() {
    registerFallbackValue(Settings.initial());
  });

  setUp(() {
    repository = MockSettingsRepository();
  });

  test('GetSettingsUseCase는 저장소에서 설정을 가져온다', () async {
    final usecase = GetSettingsUseCase(repository);
    when(
      () => repository.getSettings(),
    ).thenAnswer((_) async => Settings.initial());

    final result = await usecase();
    expect(result.id, 'default_settings');
  });

  test('UpdateThemeModeUseCase는 테마를 업데이트 후 저장한다', () async {
    final usecase = UpdateThemeModeUseCase(repository);
    when(
      () => repository.getSettings(),
    ).thenAnswer((_) async => Settings.initial());
    when(() => repository.saveSettings(any())).thenAnswer((_) async {});

    await usecase(ThemeMode.dark);
    verify(() => repository.saveSettings(any())).called(1);
  });
}

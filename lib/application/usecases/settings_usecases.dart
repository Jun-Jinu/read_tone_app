import 'package:read_tone_app/domain/entities/settings.dart';
import 'package:read_tone_app/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Settings> call() {
    return _repository.getSettings();
  }
}

class SaveSettingsUseCase {
  final SettingsRepository _repository;

  SaveSettingsUseCase(this._repository);

  Future<void> call(Settings settings) {
    return _repository.saveSettings(settings);
  }
}

class ResetSettingsUseCase {
  final SettingsRepository _repository;

  ResetSettingsUseCase(this._repository);

  Future<Settings> call() {
    return _repository.resetToDefaults();
  }
}

class ObserveSettingsUseCase {
  final SettingsRepository _repository;

  ObserveSettingsUseCase(this._repository);

  Stream<Settings> call() {
    return _repository.observeSettings();
  }
}

class UpdateThemeModeUseCase {
  final SettingsRepository _repository;

  UpdateThemeModeUseCase(this._repository);

  Future<void> call(ThemeMode themeMode) async {
    final currentSettings = await _repository.getSettings();
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    return _repository.saveSettings(updatedSettings);
  }
}

class UpdateFontSizeUseCase {
  final SettingsRepository _repository;

  UpdateFontSizeUseCase(this._repository);

  Future<void> call(FontSize fontSize) async {
    final currentSettings = await _repository.getSettings();
    final updatedSettings = currentSettings.copyWith(fontSize: fontSize);
    return _repository.saveSettings(updatedSettings);
  }
}

class UpdateDailyGoalUseCase {
  final SettingsRepository _repository;

  UpdateDailyGoalUseCase(this._repository);

  Future<void> call({required bool isEnabled, int? minutes}) async {
    final currentSettings = await _repository.getSettings();
    final updatedSettings = currentSettings.copyWith(
      isDailyGoalEnabled: isEnabled,
      dailyReadingGoalMinutes:
          minutes ?? currentSettings.dailyReadingGoalMinutes,
    );
    return _repository.saveSettings(updatedSettings);
  }
}

class UpdateReadingReminderUseCase {
  final SettingsRepository _repository;

  UpdateReadingReminderUseCase(this._repository);

  Future<void> call({
    required ReadingReminder reminder,
    required bool enableNotifications,
  }) async {
    final currentSettings = await _repository.getSettings();
    final updatedSettings = currentSettings.copyWith(
      readingReminder: reminder,
      enableNotifications: enableNotifications,
    );
    return _repository.saveSettings(updatedSettings);
  }
}

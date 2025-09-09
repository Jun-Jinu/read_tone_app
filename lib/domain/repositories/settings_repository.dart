import 'package:read_tone_app/domain/entities/settings.dart';

abstract class SettingsRepository {
  /// 현재 설정 불러오기
  Future<Settings> getSettings();

  /// 설정 저장하기
  Future<void> saveSettings(Settings settings);

  /// 설정을 기본값으로 초기화
  Future<Settings> resetToDefaults();

  /// 스트림으로 설정 변경 관찰
  Stream<Settings> observeSettings();
}

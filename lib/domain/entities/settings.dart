import 'package:flutter/material.dart';

enum ThemeMode {
  system, // 시스템 설정에 따름
  light, // 라이트 테마
  dark, // 다크 테마
}

enum FontSize {
  small,
  medium,
  large,
}

enum ReadingReminder {
  off,
  daily,
  weekdays,
  weekends,
  custom,
}

class Settings {
  final String id;
  final ThemeMode themeMode;
  final FontSize fontSize;
  final bool isDailyGoalEnabled;
  final int dailyReadingGoalMinutes;
  final ReadingReminder readingReminder;
  final TimeOfDay? reminderTime;
  final List<int>? reminderDays; // 1(월요일) ~ 7(일요일), custom 모드에서 사용
  final bool enableReadingStatistics;
  final bool enableNotifications;
  final bool enableSoundEffects;
  final bool enableHapticFeedback;
  final String? fontFamily;

  const Settings({
    required this.id,
    this.themeMode = ThemeMode.system,
    this.fontSize = FontSize.medium,
    this.isDailyGoalEnabled = true,
    this.dailyReadingGoalMinutes = 30,
    this.readingReminder = ReadingReminder.off,
    this.reminderTime,
    this.reminderDays,
    this.enableReadingStatistics = true,
    this.enableNotifications = true,
    this.enableSoundEffects = true,
    this.enableHapticFeedback = true,
    this.fontFamily,
  });

  Settings copyWith({
    String? id,
    ThemeMode? themeMode,
    FontSize? fontSize,
    bool? isDailyGoalEnabled,
    int? dailyReadingGoalMinutes,
    ReadingReminder? readingReminder,
    TimeOfDay? reminderTime,
    List<int>? reminderDays,
    bool? enableReadingStatistics,
    bool? enableNotifications,
    bool? enableSoundEffects,
    bool? enableHapticFeedback,
    String? fontFamily,
  }) {
    return Settings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      isDailyGoalEnabled: isDailyGoalEnabled ?? this.isDailyGoalEnabled,
      dailyReadingGoalMinutes:
          dailyReadingGoalMinutes ?? this.dailyReadingGoalMinutes,
      readingReminder: readingReminder ?? this.readingReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      enableReadingStatistics:
          enableReadingStatistics ?? this.enableReadingStatistics,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  // 초기 기본 설정 인스턴스를 생성하는 팩토리 메서드
  factory Settings.initial() {
    return Settings(
      id: 'default_settings',
      themeMode: ThemeMode.system,
      fontSize: FontSize.medium,
      isDailyGoalEnabled: true,
      dailyReadingGoalMinutes: 30,
      readingReminder: ReadingReminder.off,
      enableReadingStatistics: true,
      enableNotifications: true,
      enableSoundEffects: true,
      enableHapticFeedback: true,
    );
  }
}

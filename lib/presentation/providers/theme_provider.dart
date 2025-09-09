import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 테마 모드 enum
enum AppThemeMode {
  light,
  dark,
  system,
}

// 테마 상태 클래스
class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // ThemeMode로 변환
  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// 테마 관리 Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  // 저장된 테마 설정 로드
  Future<void> _loadTheme() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey) ?? 'system';

      final themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeString,
        orElse: () => AppThemeMode.system,
      );

      state = state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 테마 변경
  Future<void> changeTheme(AppThemeMode newTheme) async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newTheme.name);

      state = state.copyWith(
        themeMode: newTheme,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Provider 인스턴스
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// 편의 Providers
final currentThemeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

final materialThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).materialThemeMode;
});

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1db954);
  static const Color primaryDark = Color(0xFF169C46);
  static const Color primaryLight = Color(0xFF1ED760);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Accent Colors
  static const Color accent = Color(0xFFEC4899);
  static const Color accentLight = Color(0xFFF472B6);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> accentGradient = [accent, accentLight];

  // 메인 컬러 (하늘색 계열)
  static const Color main = Color(0xFF1DB954); // 스포티파이 그린
  static const Color mainLight = Color(0xFF1ED760); // 밝은 그린
  static const Color mainDark = Color(0xFF169C46); // 어두운 그린

  // 파스텔 액센트 컬러
  static const Color accent1 = Color(0xFFF8D7DA); // 파스텔 핑크
  static const Color accent2 = Color(0xFFD1E7DD); // 파스텔 민트
  static const Color accent3 = Color(0xFFFFE5D4); // 파스텔 코랄
  static const Color accent4 = Color(0xFFE2D5F8); // 파스텔 라벤더
  static const Color accent5 = Color(0xFFFFF3CD); // 파스텔 옐로우

  // 중립 컬러
  static const Color neutral1 = Color(0xFFFFFFFF); // 화이트
  static const Color neutral2 = Color(0xFFF8F9FA); // 라이트 그레이
  static const Color neutral3 = Color(0xFF6C757D); // 그레이
  static const Color neutral4 = Color(0xFF212529); // 다크 그레이

  // 다크 테마용 색상
  static const Color darkMain = Color(0xFF7BA4C2); // 어두운 하늘색
  static const Color darkAccent1 = Color(0xFFD4A5AD); // 어두운 파스텔 핑크
  static const Color darkAccent2 = Color(0xFFA4C4B4); // 어두운 파스텔 민트
  static const Color darkAccent3 = Color(0xFFD4B5A4); // 어두운 파스텔 코랄
  static const Color darkAccent4 = Color(0xFFB5A4D4); // 어두운 파스텔 라벤더
  static const Color darkAccent5 = Color(0xFFD4C5A4); // 어두운 파스텔 옐로우
  static const Color darkNeutral1 = Color(0xFF2C2C2C); // 다크 배경
  static const Color darkNeutral2 = Color(0xFF3C3C3C); // 다크 서피스

  // 위젯 컬러
  static const Color darkOutline = Color(0xFF4C4C4C);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceVariant = Color(0xFF3C3C3C);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFD0D0D0);

  // 독서 상태별 색상
  static const Color readingStatusPlanned = Color(0xFFFFC107); // 노란색 (읽을 예정)
  static const Color readingStatusReading = Color(0xFF2196F3); // 파란색 (읽는 중)
  static const Color readingStatusCompleted = Color(0xFF4CAF50); // 초록색 (완료)
  static const Color readingStatusPaused = Color(0xFFFF9800); // 주황색 (읽기 중지)
}

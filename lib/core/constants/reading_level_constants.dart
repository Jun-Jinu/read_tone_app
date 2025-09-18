import 'package:flutter/material.dart';

/// 독서 레벨 시스템 - 책갈피 컬러 진화
class ReadingLevelConstants {
  // 레벨별 독서량 범위 (완독한 책 수 기준)
  static const Map<int, Map<String, dynamic>> levelData = {
    1: {
      'minBooks': 0,
      'maxBooks': 4,
      'title': '입문 독서가',
      'subtitle': '첫걸음을 뗀 독서가',
      'description': '독서의 즐거움을 발견해가는 시작 단계입니다',

      'color': Color(0xFFE8F5E9), // Mint pastel
      'accentColor': Color(0xFFC8E6C9),

      'textColor': Color(0xFF2E7D32),
      'icon': Icons.bookmark_outlined,
      'gradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      // 'color': Color(0xFFFFF8E1), // Soft cream
      // 'accentColor': Color(0xFFFFE0B2),
      // 'textColor': Color(0xFF6D4C41),
      // 'icon': Icons.bookmark_border_outlined,
      // 'gradient': [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
    },
    2: {
      'minBooks': 5,
      'maxBooks': 9,
      'title': '성실한 독서가',
      'subtitle': '독서가 습관이 된 단계',
      'description': '꾸준한 독서 습관이 자리잡기 시작했어요',
      'color': Color(0xFFE8F5E9), // Mint pastel
      'accentColor': Color(0xFFC8E6C9),
      'textColor': Color(0xFF2E7D32),
      'icon': Icons.bookmark_outlined,
      'gradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    },
    3: {
      'minBooks': 10,
      'maxBooks': 19,
      'title': '꾸준한 독서가',
      'subtitle': '꾸준함이 빛나는 독서가',
      'description': '안정적인 독서 리듬을 찾아가고 있어요',
      'color': Color(0xFFE3F2FD), // Sky pastel
      'accentColor': Color(0xFFBBDEFB),
      'textColor': Color(0xFF1565C0),
      'icon': Icons.bookmark,
      'gradient': [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    },
    4: {
      'minBooks': 20,
      'maxBooks': 34,
      'title': '몰입 독서가',
      'subtitle': '독서에 깊이 빠진 독서가',
      'description': '책에 완전히 몰입하며 즐거움을 만끽하고 있어요',
      'color': Color(0xFFFFF3E0), // Warm peach
      'accentColor': Color(0xFFFFCC80),
      'textColor': Color(0xFFE65100),
      'icon': Icons.bookmark_rounded,
      'gradient': [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    },
    5: {
      'minBooks': 35,
      'maxBooks': 54,
      'title': '탐구 독서가',
      'subtitle': '지식의 깊이를 탐구하는 독서가',
      'description': '다양한 분야의 지식을 깊이 있게 탐구하고 있어요',
      'color': Color(0xFFF3E5F5), // Lavender
      'accentColor': Color(0xFFE1BEE7),
      'textColor': Color(0xFF4A148C),
      'icon': Icons.bookmark_add_rounded,
      'gradient': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    },
    6: {
      'minBooks': 55,
      'maxBooks': 79,
      'title': '성숙한 독서가',
      'subtitle': '지혜로운 안목의 독서가',
      'description': '성숙한 지적 안목으로 책을 선별하여 읽고 있어요',
      'color': Color(0xFFEDE7F6), // Indigo pastel
      'accentColor': Color(0xFFD1C4E9),
      'textColor': Color(0xFF311B92),
      'icon': Icons.auto_stories_rounded,
      'gradient': [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    },
    7: {
      'minBooks': 80,
      'maxBooks': 999,
      'title': '마스터 독서가',
      'subtitle': '독서의 달인',
      'description': '독서의 모든 영역을 마스터한 진정한 독서 마스터입니다',
      'color': Color(0xFFFFFDE7), // Soft gold
      'accentColor': Color(0xFFFFF59D),
      'textColor': Color(0xFF6D4C41),
      'icon': Icons.workspace_premium_rounded,
      'gradient': [Color(0xFFFFFDE7), Color(0xFFFFF59D)],
      'special': true, // 특별 레벨 마크
    },
  };

  /// 완독한 책 수를 기반으로 현재 레벨 계산
  static int calculateLevel(int completedBooks) {
    for (int level = 7; level >= 1; level--) {
      final data = levelData[level]!;
      if (completedBooks >= data['minBooks']) {
        return level;
      }
    }
    return 1; // 최소 레벨
  }

  /// 현재 레벨의 데이터 가져오기
  static Map<String, dynamic> getLevelData(int level) {
    return levelData[level] ?? levelData[1]!;
  }

  /// 다음 레벨까지 필요한 책 수 계산
  static int getBooksToNextLevel(int completedBooks) {
    final currentLevel = calculateLevel(completedBooks);
    if (currentLevel >= 7) return 0; // 최대 레벨 달성

    final nextLevelData = levelData[currentLevel + 1]!;
    return nextLevelData['minBooks'] - completedBooks;
  }

  /// 현재 레벨에서의 진행률 계산 (0.0 ~ 1.0)
  static double getLevelProgress(int completedBooks) {
    final currentLevel = calculateLevel(completedBooks);
    final currentLevelData = levelData[currentLevel]!;

    if (currentLevel >= 7) return 1.0; // 최대 레벨 달성

    final minBooks = currentLevelData['minBooks'] as int;
    final maxBooks = currentLevelData['maxBooks'] as int;

    if (completedBooks >= maxBooks) return 1.0;

    final progress = (completedBooks - minBooks) / (maxBooks - minBooks);
    return progress.clamp(0.0, 1.0);
  }

  /// 레벨업 축하 메시지 생성
  static String getLevelUpMessage(int newLevel) {
    final data = getLevelData(newLevel);
    final title = data['title'] as String;

    switch (newLevel) {
      case 2:
        return '축하합니다! "$title" 단계에 도달했어요!\n독서 습관이 자리잡고 있네요!';
      case 3:
        return '멋져요! "$title" 단계입니다!\n꾸준한 독서로 안정적인 리듬을 찾았어요!';
      case 4:
        return '대단해요! "$title" 단계에 진입했어요!\n독서에 완전히 몰입하고 계시네요!';
      case 5:
        return '훌륭합니다! "$title" 단계입니다!\n지식의 깊이를 탐구하는 진정한 독서가예요!';
      case 6:
        return '놀라워요! "$title" 단계에 도달했어요!\n성숙한 지적 안목을 갖추셨네요!';
      case 7:
        return '축하합니다! "$title"가 되셨어요!\n독서의 모든 영역을 마스터한 진정한 달인입니다!';
      default:
        return '축하합니다! "$title" 단계에 도달했어요!';
    }
  }

  /// 레벨별 특별 혜택 설명
  static List<String> getLevelBenefits(int level) {
    switch (level) {
      case 1:
        return ['독서 기록 시작', '기본 통계 확인'];
      case 2:
        return ['독서 습관 트래킹', '주간 독서 목표 설정'];
      case 3:
        return ['월간 독서 리포트', '독서 패턴 분석'];
      case 4:
        return ['독서 커뮤니티 참여', '북마크 고급 기능'];
      case 5:
        return ['개인화된 도서 추천', '독서 노트 고급 템플릿'];
      case 6:
        return ['전문 독서 코치 상담', '독서 클럽 우선 참여'];
      case 7:
        return ['독서 마스터 인증서', '특별 이벤트 초대', '프리미엄 기능 무제한'];
      default:
        return ['기본 기능 이용 가능'];
    }
  }
}

/// 독서 레벨 관련 유틸리티 클래스
class ReadingLevelUtils {
  /// 레벨에 따른 배지 텍스트 생성
  static String getLevelBadgeText(int level) {
    return 'Lv.$level';
  }

  /// 레벨에 따른 그라데이션 색상
  static Gradient getLevelGradient(int level) {
    final data = ReadingLevelConstants.getLevelData(level);
    final gradientColors = data['gradient'] as List<Color>;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );
  }

  /// 특별 레벨인지 확인 (7레벨 골드 마스터)
  static bool isSpecialLevel(int level) {
    final data = ReadingLevelConstants.getLevelData(level);
    return data['special'] == true;
  }
}

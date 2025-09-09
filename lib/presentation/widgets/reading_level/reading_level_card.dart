import 'package:flutter/material.dart';
import '../../../core/constants/reading_level_constants.dart';

/// 독서 레벨을 표시하는 메인 카드 위젯
class ReadingLevelCard extends StatelessWidget {
  final int completedBooks;
  final bool showProgress;
  final bool isCompact;

  const ReadingLevelCard({
    super.key,
    required this.completedBooks,
    this.showProgress = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = ReadingLevelConstants.calculateLevel(completedBooks);
    final levelData = ReadingLevelConstants.getLevelData(currentLevel);
    final progress = ReadingLevelConstants.getLevelProgress(completedBooks);
    final booksToNext =
        ReadingLevelConstants.getBooksToNextLevel(completedBooks);
    final isSpecial = ReadingLevelUtils.isSpecialLevel(currentLevel);

    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        gradient: ReadingLevelUtils.getLevelGradient(currentLevel),
        borderRadius: BorderRadius.circular(isCompact ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: (levelData['color'] as Color).withOpacity(0.3),
            blurRadius: isCompact ? 8 : 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isSpecial
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 레벨 헤더
          Row(
            children: [
              // 레벨 배지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSpecial
                      ? Colors.white.withOpacity(0.9)
                      : (levelData['textColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: isSpecial
                      ? Border.all(
                          color: levelData['accentColor'] as Color,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      levelData['icon'] as IconData,
                      size: isCompact ? 16 : 18,
                      color: isSpecial
                          ? levelData['color'] as Color
                          : levelData['textColor'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ReadingLevelUtils.getLevelBadgeText(currentLevel),
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: isSpecial
                            ? levelData['color'] as Color
                            : levelData['textColor'] as Color,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSpecial) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.9),
                  size: isCompact ? 20 : 24,
                ),
              ],

              const Spacer(),

              // 완독 책 수
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedBooks권',
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: levelData['textColor'] as Color,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isCompact ? 12 : 16),

          // 레벨 제목과 설명
          Text(
            levelData['title'] as String,
            style: TextStyle(
              fontSize: isCompact ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: levelData['textColor'] as Color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            levelData['subtitle'] as String,
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              color: (levelData['textColor'] as Color).withOpacity(0.8),
            ),
          ),

          if (!isCompact) ...[
            const SizedBox(height: 8),
            Text(
              levelData['description'] as String,
              style: TextStyle(
                fontSize: 13,
                color: (levelData['textColor'] as Color).withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],

          // 진행률 표시
          if (showProgress && currentLevel < 7) ...[
            SizedBox(height: isCompact ? 12 : 16),
            _buildProgressSection(
              context,
              currentLevel,
              progress,
              booksToNext,
              levelData,
              isCompact,
            ),
          ],

          // 최대 레벨 달성 표시
          if (currentLevel >= 7) ...[
            SizedBox(height: isCompact ? 12 : 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: levelData['textColor'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '독서 마스터 달성!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: levelData['textColor'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    int currentLevel,
    double progress,
    int booksToNext,
    Map<String, dynamic> levelData,
    bool isCompact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '다음 레벨까지',
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: (levelData['textColor'] as Color).withOpacity(0.8),
              ),
            ),
            Text(
              '$booksToNext권 남음',
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: levelData['textColor'] as Color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 진행률 바
        Container(
          height: isCompact ? 6 : 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(isCompact ? 3 : 4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(isCompact ? 3 : 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '${(progress * 100).round()}% 완료',
          style: TextStyle(
            fontSize: isCompact ? 10 : 12,
            color: (levelData['textColor'] as Color).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// 간단한 레벨 배지 위젯
class ReadingLevelBadge extends StatelessWidget {
  final int completedBooks;
  final double size;
  final bool showText;

  const ReadingLevelBadge({
    super.key,
    required this.completedBooks,
    this.size = 40,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = ReadingLevelConstants.calculateLevel(completedBooks);
    final levelData = ReadingLevelConstants.getLevelData(currentLevel);
    final isSpecial = ReadingLevelUtils.isSpecialLevel(currentLevel);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ReadingLevelUtils.getLevelGradient(currentLevel),
        shape: BoxShape.circle,
        border: isSpecial
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (levelData['color'] as Color).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            levelData['icon'] as IconData,
            size: size * 0.5,
            color: levelData['textColor'] as Color,
          ),
          if (showText)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lv.$currentLevel',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: levelData['color'] as Color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 레벨업 축하 다이얼로그
class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final int completedBooks;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.completedBooks,
  });

  @override
  Widget build(BuildContext context) {
    final levelData = ReadingLevelConstants.getLevelData(newLevel);
    final message = ReadingLevelConstants.getLevelUpMessage(newLevel);
    final benefits = ReadingLevelConstants.getLevelBenefits(newLevel);
    final isSpecial = ReadingLevelUtils.isSpecialLevel(newLevel);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: ReadingLevelUtils.getLevelGradient(newLevel),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 축하 아이콘
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSpecial ? Icons.emoji_events : Icons.auto_awesome,
                size: 48,
                color: levelData['textColor'] as Color,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'LEVEL UP!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: levelData['textColor'] as Color,
              ),
            ),

            const SizedBox(height: 8),

            ReadingLevelBadge(
              completedBooks: completedBooks,
              size: 60,
              showText: true,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: levelData['textColor'] as Color,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // 레벨 혜택
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '새로운 혜택',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: levelData['textColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...benefits.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: levelData['textColor'] as Color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              benefit,
                              style: TextStyle(
                                fontSize: 12,
                                color: levelData['textColor'] as Color,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: levelData['color'] as Color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 인라인 레벨 표시 위젯
class InlineReadingLevel extends StatelessWidget {
  final int completedBooks;

  const InlineReadingLevel({
    super.key,
    required this.completedBooks,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = ReadingLevelConstants.calculateLevel(completedBooks);
    final levelData = ReadingLevelConstants.getLevelData(currentLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: ReadingLevelUtils.getLevelGradient(currentLevel),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            levelData['icon'] as IconData,
            size: 14,
            color: levelData['textColor'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            'Lv.$currentLevel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: levelData['textColor'] as Color,
            ),
          ),
        ],
      ),
    );
  }
}

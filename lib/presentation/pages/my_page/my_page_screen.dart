import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/reading_level_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/common/feature_restriction_card.dart';
import '../../widgets/reading_level/reading_level_card.dart';
import 'package:read_tone_app/domain/entities/book.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final booksAsyncValue = ref.watch(booksProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isGuest = authState.isGuest;
    final currentUser = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, ref),
              _buildProfileSection(
                context,
                ref,
                isAuthenticated,
                isGuest,
                currentUser,
              ),
              const SizedBox(height: 32),

              // 독서 레벨 카드
              booksAsyncValue.when(
                data: (books) => _buildReadingLevelSection(context, books),
                loading: () => _buildLevelLoadingCard(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // 통계 페이지로 이동 카드
              _buildStatisticsNavigationCard(context),

              // 비회원인 경우 추가 기능 제한 안내
              if (isGuest) ...[
                const SizedBox(height: 32),
                _buildGuestFeatureHint(context, ref),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마이페이지',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () {
                context.push('/settings');
              },
              tooltip: '설정',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    bool isAuthenticated,
    bool isGuest,
    dynamic currentUser,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 정보
          Row(
            children: [
              // 프로필 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  isGuest ? Icons.person_outline : Icons.person,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? '게스트 사용자' : currentUser?.displayName ?? '사용자',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGuest
                          ? '로그인하여 더 많은 기능을 이용해보세요'
                          : currentUser?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isGuest) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('로그인하기'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (isAuthenticated) ...[
            const SizedBox(height: 24),
            // 계정 관리 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/profile-edit');
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('프로필 편집'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // TODO: 프리미엄 관련 안내로 수정
                // const SizedBox(width: 12),
                // Expanded(
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       ref.read(authProvider.notifier).signOut();
                //     },
                //     icon: const Icon(Icons.logout_outlined),
                //     label: const Text('로그아웃'),
                //     style: OutlinedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsNavigationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 독서 통계',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '자세한 독서 통계와 분석을 확인해보세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/statistics');
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('통계 보러가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // const SizedBox(width: 12),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).colorScheme.primaryContainer,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: IconButton(
              //     onPressed: () {
              //       context.push('/share?isBookSpecific=false');
              //     },
              //     icon: Icon(
              //       Icons.share_rounded,
              //       color: Theme.of(context).colorScheme.primary,
              //     ),
              //     tooltip: '통계 공유하기',
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingLevelSection(BuildContext context, List<Book> books) {
    final completedBooks = books
        .where((book) => book.status == BookStatus.completed)
        .length;
    final currentLevel = ReadingLevelConstants.calculateLevel(completedBooks);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '나의 독서 레벨',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAllLevelsDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '레벨 정보',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 레벨 카드
          ReadingLevelCard(
            completedBooks: completedBooks,
            showProgress: true,
            isCompact: false,
          ),

          const SizedBox(height: 16),

          // 레벨 혜택 미리보기
          _buildLevelBenefitsPreview(context, currentLevel),
        ],
      ),
    );
  }

  Widget _buildLevelBenefitsPreview(BuildContext context, int currentLevel) {
    final benefits = ReadingLevelConstants.getLevelBenefits(currentLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '현재 레벨 혜택',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...benefits
              .take(3)
              .map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (benefits.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '그 외 ${benefits.length - 3}개 혜택',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelLoadingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const Spacer(),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllLevelsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '독서 레벨 시스템',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final levelData = ReadingLevelConstants.getLevelData(level);
                    final isSpecial = ReadingLevelUtils.isSpecialLevel(level);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: ReadingLevelUtils.getLevelGradient(level),
                        borderRadius: BorderRadius.circular(16),
                        border: isSpecial
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              levelData['icon'] as IconData,
                              color: levelData['textColor'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Lv.$level',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: levelData['textColor'] as Color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      levelData['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: levelData['textColor'] as Color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${levelData['minBooks']}권 ${level < 7 ? '~ ${levelData['maxBooks']}권' : '이상'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: (levelData['textColor'] as Color)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSpecial)
                            Icon(
                              Icons.auto_awesome,
                              color: levelData['textColor'] as Color,
                              size: 20,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestFeatureHint(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FeatureRestrictionCard(
        title: '더 많은 기능을 사용해보세요!',
        description: '로그인하시면 클라우드 동기화, 상세 통계, 독서 목표 설정 등의 기능을 이용할 수 있어요.',
        icon: Icons.star_outline,
        buttonText: '로그인 혜택 보기',
        onButtonPressed: () {
          context.push('/login-benefits');
        },
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/feature_restriction_card.dart';
import 'package:read_tone_app/domain/entities/book.dart';

// 통계 기간 선택을 위한 enum
enum StatisticsPeriod { week, month, year, all }

// 통계 기간 상태 관리를 위한 StateProvider
final statisticsPeriodProvider = StateProvider<StatisticsPeriod>(
  (ref) => StatisticsPeriod.all,
);

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksProvider);
    final authState = ref.watch(authProvider);
    final isGuest = authState.isGuest;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, ref),
              booksAsyncValue.when(
                data: (books) =>
                    _buildStatisticsContent(context, ref, books, isGuest),
                loading: () => _buildStatisticsLoadingSection(context),
                error: (error, stack) => _buildErrorState(context, error),
              ),
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
                  '통계',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.primaryContainer,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: IconButton(
          //     icon: Icon(
          //       Icons.share_rounded,
          //       color: Theme.of(context).colorScheme.primary,
          //       size: 20,
          //     ),
          //     onPressed: () {
          //       context.push('/share?isBookSpecific=false');
          //     },
          //     tooltip: '통계 공유하기',
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(
    BuildContext context,
    WidgetRef ref,
    List<Book> books,
    bool isGuest,
  ) {
    final selectedPeriod = ref.watch(statisticsPeriodProvider);
    final filteredBooks = _getFilteredBooks(books, selectedPeriod);
    final completedBooks = filteredBooks
        .where((book) => book.status == BookStatus.completed)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 비회원 안내 메시지
          if (isGuest && books.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '비회원 모드에서는 기본 통계만 제공됩니다. 더 많은 기능을 원하시면 로그인해주세요!',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          _buildPeriodSelector(context, ref),
          const SizedBox(height: 24),
          _buildCombinedStatisticsCard(
            context,
            filteredBooks,
            completedBooks,
            selectedPeriod,
          ),
          const SizedBox(height: 24),
          if (completedBooks.isNotEmpty) ...[
            _buildSectionHeader(context, '최근 완독한 책'),
            const SizedBox(height: 16),
            _buildRecentCompletedBooks(context, completedBooks),
            const SizedBox(height: 24),
          ],

          // 비회원인 경우 추가 기능 제한 안내
          // if (isGuest) ...[
          //   FeatureRestrictionCard(
          //     title: '더 자세한 통계를 원하시나요?',
          //     description: '로그인하시면 더 다양한 독서 통계와 분석을 확인할 수 있어요.',
          //     icon: Icons.analytics_outlined,
          //     buttonText: '로그인하기',
          //     onButtonPressed: () {
          //       context.push('/login-benefits');
          //     },
          //   ),
          //   const SizedBox(height: 24),
          // ],
        ],
      ),
    );
  }

  Widget _buildStatisticsLoadingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 선택 로딩
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          // 오버뷰 카드 로딩
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          // 최근 완독한 책 로딩
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '통계를 불러올 수 없어요',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시 후 다시 시도해주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 기간별 필터링 함수
  List<Book> _getFilteredBooks(List<Book> books, StatisticsPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case StatisticsPeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return books.where((book) {
          final completedAt = book.completedAt;
          return completedAt != null &&
              completedAt.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              completedAt.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();

      case StatisticsPeriod.month:
        return books.where((book) {
          final completedAt = book.completedAt;
          return completedAt != null &&
              completedAt.year == now.year &&
              completedAt.month == now.month;
        }).toList();

      case StatisticsPeriod.year:
        return books.where((book) {
          final completedAt = book.completedAt;
          return completedAt != null && completedAt.year == now.year;
        }).toList();

      case StatisticsPeriod.all:
        return books;
    }
  }

  // 기간 선택 위젯
  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(statisticsPeriodProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = selectedPeriod == period;
          String label;
          switch (period) {
            case StatisticsPeriod.week:
              label = '주';
              break;
            case StatisticsPeriod.month:
              label = '월';
              break;
            case StatisticsPeriod.year:
              label = '년';
              break;
            case StatisticsPeriod.all:
              label = '전체';
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(statisticsPeriodProvider.notifier).state = period;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 통합 통계 카드 (기존 마이페이지에서 이동)
  Widget _buildCombinedStatisticsCard(
    BuildContext context,
    List<Book> filteredBooks,
    List<Book> completedBooks,
    StatisticsPeriod period,
  ) {
    // 데이터가 없는 경우 안내 위젯 표시
    if (completedBooks.isEmpty) {
      return _buildEmptyStatisticsCard(context, period);
    }

    final totalPages = completedBooks.fold<int>(
      0,
      (sum, book) => sum + book.totalPages,
    );
    final averagePages = completedBooks.isEmpty
        ? 0
        : (totalPages / completedBooks.length).round();
    final mainGenre = _getMainGenre(completedBooks);

    return Container(
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
          // 총 페이지 수와 기타 통계
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalPages.toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '총 페이지',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatText(
                context,
                '읽은 책 수',
                completedBooks.length.toString(),
              ),
              _buildStatText(context, '평균 페이지', averagePages.toString()),
              _buildStatText(context, '주요 장르', mainGenre),
            ],
          ),
          const SizedBox(height: 32),
          // 기간별 차트
          _buildPeriodChart(context, completedBooks, period),
        ],
      ),
    );
  }

  // 데이터가 없을 때 표시하는 안내 카드
  Widget _buildEmptyStatisticsCard(
    BuildContext context,
    StatisticsPeriod period,
  ) {
    String title;
    String description;
    String emoji;

    switch (period) {
      case StatisticsPeriod.week:
        title = '이번 주 완독한 책이 없어요';
        description = '이번 주에는 아직 완독한 책이 없습니다.\n새로운 책을 시작해보는 건 어떨까요?';
        emoji = '📅';
        break;
      case StatisticsPeriod.month:
        title = '이번 달 완독한 책이 없어요';
        description = '이번 달에는 아직 완독한 책이 없습니다.\n독서 목표를 세워보세요!';
        emoji = '📆';
        break;
      case StatisticsPeriod.year:
        title = '올해 완독한 책이 없어요';
        description = '올해는 아직 완독한 책이 없습니다.\n새해 독서 계획을 시작해보세요!';
        emoji = '🗓️';
        break;
      case StatisticsPeriod.all:
        title = '아직 완독한 책이 없어요';
        description = '첫 번째 책을 완독하고\n멋진 독서 여정을 시작해보세요!';
        emoji = '📚';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(32),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push('/search');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '책 검색하러 가기',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatText(BuildContext context, String title, String value) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getMainGenre(List<Book> books) {
    if (books.isEmpty) return '-';

    // 장르별 카운트
    final genreCount = <String, int>{};
    for (final book in books) {
      final genre = _inferGenreFromTitle(book.title);
      genreCount[genre] = (genreCount[genre] ?? 0) + 1;
    }

    if (genreCount.isEmpty) return '-';

    // 가장 많은 장르 반환
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedGenres.first.key;
  }

  String _inferGenreFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('소설') || lowerTitle.contains('novel')) return '소설';
    if (lowerTitle.contains('경영') || lowerTitle.contains('비즈니스'))
      return '경영/비즈니스';
    if (lowerTitle.contains('자기계발') || lowerTitle.contains('성공')) return '자기계발';
    if (lowerTitle.contains('역사')) return '역사';
    if (lowerTitle.contains('과학') || lowerTitle.contains('기술')) return '과학/기술';
    if (lowerTitle.contains('철학')) return '철학';
    if (lowerTitle.contains('예술') || lowerTitle.contains('문화')) return '예술/문화';
    if (lowerTitle.contains('요리') || lowerTitle.contains('레시피')) return '요리';
    if (lowerTitle.contains('여행')) return '여행';
    if (lowerTitle.contains('건강') || lowerTitle.contains('의학')) return '건강/의학';
    if (lowerTitle.contains('교육') || lowerTitle.contains('학습')) return '교육';
    if (lowerTitle.contains('종교') || lowerTitle.contains('영성')) return '종교/영성';
    return '기타';
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecentCompletedBooks(
    BuildContext context,
    List<Book> completedBooks,
  ) {
    final recentBooks =
        completedBooks
            .where((book) => book.status == BookStatus.completed)
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (recentBooks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 완독한 책이 없어요',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '첫 번째 책을 완독해보세요! 📚',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentBooks.take(3).map((book) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildBookItem(context, book),
        );
      }).toList(),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        context.push('/book/${book.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book.coverImageUrl,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.book_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '완독일: ${_formatDate(book.completedAt!)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 차트 관련 함수들 (마이페이지에서 이동)
  List<FlSpot> _getWeeklyChartData(List<Book> books) {
    final weekData = List.generate(7, (index) => 0);

    for (final book in books) {
      if (book.completedAt != null) {
        final dayIndex = book.completedAt!.weekday - 1; // 월요일 = 0
        if (dayIndex >= 0 && dayIndex < 7) {
          weekData[dayIndex]++;
        }
      }
    }

    return weekData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();
  }

  List<FlSpot> _getMonthlyChartData(List<Book> books) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthData = List.generate(daysInMonth, (index) => 0);

    for (final book in books) {
      if (book.completedAt != null &&
          book.completedAt!.month == now.month &&
          book.completedAt!.year == now.year) {
        final dayIndex = book.completedAt!.day - 1;
        if (dayIndex >= 0 && dayIndex < daysInMonth) {
          monthData[dayIndex]++;
        }
      }
    }

    return monthData
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble() + 1, entry.value.toDouble()),
        )
        .toList();
  }

  List<FlSpot> _getYearlyChartData(List<Book> books) {
    final now = DateTime.now();
    final yearData = List.generate(12, (index) => 0);

    for (final book in books) {
      if (book.completedAt != null && book.completedAt!.year == now.year) {
        final monthIndex = book.completedAt!.month - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          yearData[monthIndex]++;
        }
      }
    }

    return yearData
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble() + 1, entry.value.toDouble()),
        )
        .toList();
  }

  List<FlSpot> _getAllTimeChartData(List<Book> books) {
    final Map<int, int> yearlyData = {};

    for (final book in books) {
      if (book.completedAt != null) {
        final year = book.completedAt!.year;
        yearlyData[year] = (yearlyData[year] ?? 0) + 1;
      }
    }

    if (yearlyData.isEmpty) return [];

    final sortedYears = yearlyData.keys.toList()..sort();
    return sortedYears
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.value.toDouble(),
            yearlyData[entry.value]!.toDouble(),
          ),
        )
        .toList();
  }

  Widget _buildPeriodChart(
    BuildContext context,
    List<Book> books,
    StatisticsPeriod period,
  ) {
    String chartTitle;
    List<String> xLabels;
    List<FlSpot> chartData;

    switch (period) {
      case StatisticsPeriod.week:
        chartTitle = '이번주 독서 기록';
        xLabels = ['월', '화', '수', '목', '금', '토', '일'];
        chartData = _getWeeklyChartData(books);
        break;

      case StatisticsPeriod.month:
        chartTitle = '이번달 독서 기록';
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        xLabels = List.generate(daysInMonth, (index) => '${index + 1}');
        chartData = _getMonthlyChartData(books);
        break;

      case StatisticsPeriod.year:
        chartTitle = '올해 독서 기록';
        xLabels = [
          '1월',
          '2월',
          '3월',
          '4월',
          '5월',
          '6월',
          '7월',
          '8월',
          '9월',
          '10월',
          '11월',
          '12월',
        ];
        chartData = _getYearlyChartData(books);
        break;

      case StatisticsPeriod.all:
        chartTitle = '연도별 독서 기록';
        final allYears =
            books
                .where((book) => book.completedAt != null)
                .map((book) => book.completedAt!.year)
                .toSet()
                .toList()
              ..sort();
        xLabels = allYears.map((year) => '$year').toList();
        chartData = _getAllTimeChartData(books);
        break;
    }

    if (chartData.isEmpty) {
      return Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 완독한 책이 없습니다',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '첫 번째 책을 완독해보세요! 📚',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chartTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (period == StatisticsPeriod.week) {
                        return index >= 0 && index < xLabels.length
                            ? Text(
                                xLabels[index],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              )
                            : const SizedBox.shrink();
                      } else if (period == StatisticsPeriod.month) {
                        return index >= 0 &&
                                index < xLabels.length &&
                                (index % 5 == 0 || index == xLabels.length - 1)
                            ? Text(
                                '${index + 1}일',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              )
                            : const SizedBox.shrink();
                      } else if (period == StatisticsPeriod.year) {
                        return index >= 0 && index < 12
                            ? Text(
                                '${index + 1}월',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              )
                            : const SizedBox.shrink();
                      } else {
                        // all time
                        return index >= 0 && index < xLabels.length
                            ? Text(
                                xLabels[index],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              barGroups: _convertToBarGroups(context, chartData),
              minY: 0,
            ),
          ),
        ),
      ],
    );
  }

  // FlSpot 데이터를 BarChartGroupData로 변환하는 메서드
  List<BarChartGroupData> _convertToBarGroups(
    BuildContext context,
    List<FlSpot> spots,
  ) {
    return spots.map((spot) {
      return BarChartGroupData(
        x: spot.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: spot.y,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
        ],
      );
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:read_tone_app/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/book.dart';

class ShareStatisticsScreen extends ConsumerStatefulWidget {
  final String? bookId; // 특정 책의 통계를 공유할 때 사용
  final bool isBookSpecific; // 특정 책 통계인지 전체 통계인지 구분

  const ShareStatisticsScreen({
    super.key,
    this.bookId,
    this.isBookSpecific = false,
  });

  @override
  ConsumerState<ShareStatisticsScreen> createState() =>
      _ShareStatisticsScreenState();
}

class _ShareStatisticsScreenState extends ConsumerState<ShareStatisticsScreen> {
  String _selectedPeriod = '전체';
  final GlobalKey _statisticsKey = GlobalKey();

  Future<void> _shareAsImage() async {
    try {
      // 위젯을 이미지로 변환
      RenderRepaintBoundary boundary =
          _statisticsKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.isBookSpecific
            ? 'book_stats.png'
            : 'reading_stats.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        // 공유
        await Share.shareXFiles([
          XFile(file.path),
        ], text: widget.isBookSpecific ? '나의 독서 기록' : '나의 독서 통계');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 생성 중 오류가 발생했습니다: $e')));
      }
    }
  }

  Future<void> _shareAsText() async {
    final authState = ref.read(authProvider);
    final booksAsyncValue = ref.read(booksProvider);

    await booksAsyncValue.when(
      data: (books) async {
        String shareText;

        if (widget.isBookSpecific && widget.bookId != null) {
          // 특정 책 공유
          try {
            final book = books.firstWhere((b) => b.id == widget.bookId);
            shareText = _generateBookShareText(book, authState.user?.name);
          } catch (e) {
            shareText = '책 정보를 찾을 수 없습니다.';
          }
        } else {
          // 전체 통계 공유
          shareText = _generateStatsShareText(books, authState.user?.name);
        }

        await Share.share(shareText);
      },
      loading: () async {
        await Share.share('독서 통계를 불러오는 중입니다...');
      },
      error: (error, stack) async {
        await Share.share('독서 통계를 불러올 수 없습니다.');
      },
    );
  }

  String _generateBookShareText(Book book, String? userName) {
    final statusText = book.status == BookStatus.completed
        ? '완독'
        : book.status == BookStatus.reading
        ? '읽는 중'
        : '읽을 예정';

    final progressText = book.status == BookStatus.completed
        ? '${book.totalPages}페이지 완독!'
        : '${book.currentPage}/${book.totalPages}페이지 (${(book.readingProgress * 100).toInt()}%)';

    return '''
📚 ${userName ?? '나'}의 독서 기록

책: ${book.title}
저자: ${book.author}
상태: $statusText
진행률: $progressText

${book.memo?.isNotEmpty == true ? '\n📝 메모: ${book.memo}' : ''}

#독서 #ReadTone''';
  }

  String _generateStatsShareText(List<Book> books, String? userName) {
    final completedBooks = books
        .where((book) => book.status == BookStatus.completed)
        .length;
    final readingBooks = books
        .where((book) => book.status == BookStatus.reading)
        .length;
    final totalPages = books
        .where((book) => book.status == BookStatus.completed)
        .fold<int>(0, (sum, book) => sum + book.totalPages);

    return '''
📊 ${userName ?? '나'}의 독서 통계 ($_selectedPeriod)

✅ 완독한 책: ${completedBooks}권
📖 읽는 중: ${readingBooks}권
📄 총 읽은 페이지: ${totalPages}페이지

${completedBooks > 0 ? '평균 페이지: ${(totalPages / completedBooks).round()}페이지' : ''}

#독서통계 #ReadTone''';
  }

  @override
  Widget build(BuildContext context) {
    final booksAsyncValue = ref.watch(booksProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBookSpecific ? '독서 기록 공유' : '독서 통계 공유'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareAsImage),
        ],
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('데이터를 불러올 수 없습니다'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(booksProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (books) {
          if (widget.isBookSpecific && widget.bookId != null) {
            try {
              final book = books.firstWhere((b) => b.id == widget.bookId);
              return _buildBookStatistics(context, book, authState.user?.name);
            } catch (e) {
              return const Center(child: Text('책을 찾을 수 없습니다.'));
            }
          } else {
            return _buildGeneralStatistics(
              context,
              books,
              authState.user?.name,
            );
          }
        },
      ),
    );
  }

  Widget _buildBookStatistics(
    BuildContext context,
    Book book,
    String? userName,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // 공유할 카드
          RepaintBoundary(
            key: _statisticsKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 앱 로고
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 사용자 이름
                  Text(
                    '${userName ?? '나'}의 독서 기록',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 책 정보
                  _buildBookInfoRow('📚 제목', book.title),
                  const SizedBox(height: 16),
                  _buildBookInfoRow('✍️ 저자', book.author),
                  const SizedBox(height: 16),
                  _buildBookInfoRow('📄 페이지', '${book.totalPages}페이지'),
                  const SizedBox(height: 16),
                  _buildBookInfoRow(
                    '📈 진행률',
                    '${(book.readingProgress * 100).toInt()}%',
                  ),

                  const SizedBox(height: 32),

                  // 상태 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(book.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(book.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 앱 이름
                  const Text(
                    'ReadTone',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 공유 옵션
          _buildShareOptions(),
        ],
      ),
    );
  }

  Widget _buildGeneralStatistics(
    BuildContext context,
    List<Book> books,
    String? userName,
  ) {
    final completedBooks = books
        .where((book) => book.status == BookStatus.completed)
        .length;
    final readingBooks = books
        .where((book) => book.status == BookStatus.reading)
        .length;
    final totalPages = books
        .where((book) => book.status == BookStatus.completed)
        .fold<int>(0, (sum, book) => sum + book.totalPages);
    final averagePages = completedBooks > 0
        ? (totalPages / completedBooks).round()
        : 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 기간 선택
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildPeriodSelector(context),
          ),

          // 통계 카드
          RepaintBoundary(
            key: _statisticsKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 앱 로고
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 제목
                  Text(
                    '${userName ?? '나'}의 독서 통계',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // 통계 데이터
                  _buildStatItem('완독한 책', '${completedBooks}권'),
                  const SizedBox(height: 20),
                  _buildStatItem('읽는 중', '${readingBooks}권'),
                  const SizedBox(height: 20),
                  _buildStatItem('총 페이지', '${totalPages}페이지'),
                  if (averagePages > 0) ...[
                    const SizedBox(height: 20),
                    _buildStatItem('평균 페이지', '${averagePages}페이지'),
                  ],

                  const SizedBox(height: 32),

                  // 앱 이름
                  const Text(
                    'ReadTone',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 공유 옵션
          _buildShareOptions(),
        ],
      ),
    );
  }

  Widget _buildBookInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShareOptions() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '공유 옵션',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('이미지로 공유'),
                  subtitle: const Text('예쁜 카드 형태로 공유하기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _shareAsImage,
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.text_snippet_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('텍스트로 공유'),
                  subtitle: const Text('간단한 텍스트로 공유하기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _shareAsText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.completed:
        return AppColors.readingStatusCompleted;
      case BookStatus.reading:
        return AppColors.readingStatusReading;
      case BookStatus.planned:
        return AppColors.readingStatusPlanned;
      case BookStatus.paused:
        return AppColors.readingStatusPaused;
    }
  }

  String _getStatusText(BookStatus status) {
    switch (status) {
      case BookStatus.completed:
        return '✅ 완독';
      case BookStatus.reading:
        return '📖 읽는 중';
      case BookStatus.planned:
        return '읽을 예정';
      case BookStatus.paused:
        return '📝 읽기 중지';
    }
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          _buildPeriodToggle(context, '주', '주'),
          _buildPeriodToggle(context, '월', '월'),
          _buildPeriodToggle(context, '년', '년'),
          _buildPeriodToggle(context, '전체', '전체'),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(BuildContext context, String title, String period) {
    final isSelected = period == _selectedPeriod;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedPeriod = period;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

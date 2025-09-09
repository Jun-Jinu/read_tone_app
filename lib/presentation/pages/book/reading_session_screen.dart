import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import '../../providers/reading_record_provider.dart';
import '../../../domain/entities/reading_record.dart';

class ReadingSessionScreen extends ConsumerStatefulWidget {
  final Book book;

  const ReadingSessionScreen({super.key, required this.book});

  @override
  ConsumerState<ReadingSessionScreen> createState() =>
      _ReadingSessionScreenState();
}

class _ReadingSessionScreenState extends ConsumerState<ReadingSessionScreen>
    with TickerProviderStateMixin {
  late DateTime startTime;
  late Duration readingTime;
  bool isReading = true;
  late int currentPage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 자동 페이지 증가 관련
  int pagesPerMinute = 1; // 기본값: 1분에 1페이지
  DateTime lastPageIncrement = DateTime.now();

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    readingTime = Duration.zero;
    currentPage = widget.book.currentPage;
    lastPageIncrement = DateTime.now();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Disable pulse animation usage for stable UI
    _fadeController.forward();
    _loadReadingSettings();
    _startTimer();
  }

  // 독서 설정 로드 (자동 페이지 증가 속도)
  Future<void> _loadReadingSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pagesPerMinute = prefs.getInt('pages_per_minute') ?? 1;
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && isReading) {
        final now = DateTime.now();
        setState(() {
          readingTime = now.difference(startTime);

          // 자동 페이지 증가 (1분마다)
          final minutesSinceLastIncrement = now
              .difference(lastPageIncrement)
              .inMinutes;
          if (minutesSinceLastIncrement >= 1) {
            final pagesToAdd = minutesSinceLastIncrement * pagesPerMinute;
            if (currentPage + pagesToAdd <= widget.book.totalPages) {
              currentPage += pagesToAdd;
              lastPageIncrement = now;
            }
          }
        });
        _startTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // 간단 페이지 업데이트 (현재 UI에서는 수동 버튼 제거됨)
  void _updatePage(int newPage) {
    if (newPage >= 0 && newPage <= widget.book.totalPages) {
      setState(() {
        currentPage = newPage;
      });
    }
  }

  void _toggleReading() {
    setState(() {
      final now = DateTime.now();
      isReading = !isReading;
      if (isReading) {
        startTime = now.subtract(readingTime);
        lastPageIncrement = now; // 재시작시 페이지 증가 타이밍 리셋
        _startTimer();
      } else {
        // paused
      }
    });
  }

  void _saveReadingProgress() {
    final record = ReadingRecord(
      bookId: widget.book.id,
      startTime: startTime,
      endTime: DateTime.now(),
      startPage: widget.book.currentPage,
      endPage: currentPage,
    );
    ref.read(readingRecordsProvider.notifier).addRecord(record);
    Navigator.pop(context);
  }

  // 빠른 책갈피 추가 모달
  Future<void> _showQuickBookmarkModal() async {
    const String usePagePrefKey = 'bookmark_use_page_enabled';

    final prefs = await SharedPreferences.getInstance();
    final bool initialUsePage =
        prefs.getBool(usePagePrefKey) ?? true; // 독서 세션에서는 기본 true

    final TextEditingController pageController = TextEditingController(
      text: currentPage.toString(), // 현재 페이지를 기본값으로
    );
    final TextEditingController quoteController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        bool usePage = initialUsePage;
        return StatefulBuilder(
          builder: (context, setState) {
            bool initialized = false;
            if (!initialized) {
              memoController.addListener(() => setState(() {}));
              initialized = true;
            }

            final bool isMemoFilled = memoController.text.trim().isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark_add,
                            color: Colors.blue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '책갈피 추가',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // 페이지 번호 사용 체크박스
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: usePage
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          width: usePage ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: usePage ? Colors.blue.withOpacity(0.04) : null,
                      ),
                      child: CheckboxListTile(
                        value: usePage,
                        onChanged: (value) async {
                          final v = value ?? false;
                          setState(() => usePage = v);
                          await prefs.setBool(usePagePrefKey, v);
                        },
                        title: Row(
                          children: [
                            Icon(
                              Icons.book,
                              color: usePage ? Colors.blue : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '페이지 번호 입력 사용',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: usePage ? Colors.blue : null,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '현재 페이지($currentPage)로 자동 설정됩니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 페이지 번호 입력 (체크 시 노출)
                    if (usePage)
                      TextFormField(
                        controller: pageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '페이지 번호 (선택)',
                          hintText: '페이지 번호를 입력하세요',
                          prefixIcon: const Icon(
                            Icons.menu_book,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (!usePage) return null;
                          if (value != null && value.isNotEmpty) {
                            final page = int.tryParse(value);
                            if (page == null) {
                              return '올바른 숫자를 입력해주세요';
                            }
                            if (page <= 0 || page > widget.book.totalPages) {
                              return '1~${widget.book.totalPages} 범위의 페이지를 입력해주세요';
                            }
                          }
                          return null;
                        },
                      ),

                    if (usePage) const SizedBox(height: 12),

                    // 구절 입력 (선택)
                    TextFormField(
                      controller: quoteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '구절 (선택)',
                        hintText: '인상 깊은 구절을 입력하세요',
                        prefixIcon: const Icon(
                          Icons.format_quote,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 메모 입력 (필수)
                    TextFormField(
                      controller: memoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '메모 (필수)',
                        hintText: '생각이나 느낌을 입력하세요',
                        prefixIcon: const Icon(
                          Icons.edit_note,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '메모를 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 8),
                        AbsorbPointer(
                          absorbing: !isMemoFilled,
                          child: Opacity(
                            opacity: isMemoFilled ? 1.0 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.lightBlue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      // TODO: 실제 책갈피 추가 로직
                                      await Future.delayed(
                                        const Duration(milliseconds: 500),
                                      );

                                      if (context.mounted) {
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: const [
                                                Icon(
                                                  Icons.bookmark_added,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text('책갈피가 추가되었습니다'),
                                              ],
                                            ),
                                            backgroundColor: Colors.blue,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (error) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '책갈피 추가 실패: ${error.toString()}',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '추가하기',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (isReading) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.pause_circle_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('독서를 종료하시겠습니까?'),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '독서 시간: ${_formatDuration(readingTime)}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '현재 페이지: $currentPage / ${widget.book.totalPages}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('계속하기'),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '종료하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
      if (shouldPop ?? false) {
        _saveReadingProgress();
      }
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildCompactAppBar(context),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildCompactTimer(context),
                          const SizedBox(height: 12),
                          _buildCompactPageInfo(context),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildCompactBottomControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _onWillPop(),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.book.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isReading ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isReading ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isReading ? '진행중' : '일시정지',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBookInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 작은 책 표지
          Container(
            width: 52,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.book.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.book_rounded,
                      size: 30,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.book.author,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '독서 시간',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDuration(readingTime),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 36,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showQuickBookmarkModal,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('책갈피 추가'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPageInfo(BuildContext context) {
    final progress = widget.book.totalPages > 0
        ? currentPage / widget.book.totalPages
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 페이지',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$currentPage / ${widget.book.totalPages}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 빠른 액션 영역은 타이머 카드 내부 버튼으로 대체됨

  Widget _buildCompactBottomControls(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + bottomInset.clamp(0.0, 24.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isReading
                      ? [Colors.orange, Colors.deepOrange]
                      : [Colors.green, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: _toggleReading,
                icon: Icon(isReading ? Icons.pause : Icons.play_arrow),
                label: Text(isReading ? '일시정지' : '계속하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: _saveReadingProgress,
                icon: const Icon(Icons.save),
                label: const Text('저장하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isReading = false;
    _fadeController.dispose();
    super.dispose();
  }
}

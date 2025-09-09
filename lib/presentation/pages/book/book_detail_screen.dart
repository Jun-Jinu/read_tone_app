import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/reading_note.dart';
import '../../providers/book_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final String bookId;
  final bool startInEditMode;

  const BookDetailScreen({
    super.key,
    required this.bookId,
    this.startInEditMode = false,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  Timer? _debounceTimer;
  bool _isEditMode = false;
  bool _isScrolled = false;
  bool _appliedStartEdit = false;

  // 편집 모드용 컨트롤러들
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _totalPagesController;
  late TextEditingController _currentPageController;
  late TextEditingController _memoController;
  late TextEditingController _coverImageUrlController;

  late BookStatus _selectedStatus;
  late bool _isFavorite;
  late int _priority;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _memoController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsyncValue = ref.watch(booksProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: _isScrolled
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: _isScrolled ? 1 : 0,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: IconButton(
            icon: Icon(
              _isEditMode ? Icons.close : Icons.arrow_back_ios,
              color: _isScrolled
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.white,
            ),
            onPressed: _isEditMode
                ? _cancelEdit
                : () => Navigator.of(context).pop(),
            tooltip: _isEditMode ? '편집 취소' : null,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(
                _isEditMode ? Icons.save : Icons.edit,
                color: _isScrolled
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white,
              ),
              onPressed: () {
                if (_isEditMode) {
                  _saveChanges();
                } else {
                  _enterEditMode();
                }
              },
              tooltip: _isEditMode ? '변경사항 저장' : '책 정보 수정',
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          //   child: IconButton(
          //     icon: Icon(
          //       Icons.share,
          //       color: _isScrolled
          //           ? Theme.of(context).colorScheme.onSurface
          //           : Colors.white,
          //     ),
          //     onPressed: () {
          //       // 책 공유 화면으로 이동
          //       context.push(
          //           '/share?bookId=${widget.bookId}&isBookSpecific=true');
          //     },
          //   ),
          // ),
        ],
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '책 정보를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(booksProvider.notifier).refreshBooks(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (books) {
          try {
            final book = books.firstWhere((book) => book.id == widget.bookId);
            // 즐겨찾기 상태 초기화 (한 번만)
            if (!_isEditMode) {
              _isFavorite = book.isFavorite;
            }
            // 쿼리 파라미터로 편집 모드 시작
            if (widget.startInEditMode && !_appliedStartEdit) {
              _appliedStartEdit = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isEditMode) {
                  _initializeControllers(book);
                  setState(() {
                    _isEditMode = true;
                  });
                }
              });
            }
            return _buildBookDetail(context, ref, book);
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '책을 찾을 수 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '요청하신 책이 존재하지 않습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBookDetail(BuildContext context, WidgetRef ref, Book book) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 스크롤 위치가 300 이상이면 AppBar 배경색 변경
        if (notification.metrics.pixels > 300) {
          if (!_isScrolled) {
            setState(() {
              _isScrolled = true;
            });
          }
        } else {
          if (_isScrolled) {
            setState(() {
              _isScrolled = false;
            });
          }
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더 섹션 (책 표지 + 기본 정보)
            _buildHeaderSection(context, book),

            // 진행률 카드
            _buildProgressCard(context, book, ref),

            // 독서 기간 카드
            _buildReadingPeriodCard(context, book),

            // 메모/리뷰 카드
            _buildMemoCard(context, book),

            // 독서 노트 카드
            _buildNotesCard(context, ref, book),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 헤더 섹션 (그라데이션 배경 + 책 표지)
  Widget _buildHeaderSection(BuildContext context, Book book) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 책 표지
              Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: book.coverImageUrl.isNotEmpty
                      ? Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.book, size: 60),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 60),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 책 제목과 즐겨찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 즐겨찾기 별표
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      // 즉시 저장
                      _updateFavoriteStatus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite
                            ? Colors.amber
                            : Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 책 제목
                  _isEditMode
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _titleController,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            book.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                  // 오른쪽 공간을 위한 placeholder (대칭을 위해)
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 8),

              // 저자
              _isEditMode
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _authorController,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      book.author,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 16),

              // 독서 상태 표시
              _buildStatusBadge(context, book),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 독서 상태 작은 배지
  Widget _buildStatusBadge(BuildContext context, Book book) {
    final statusInfo = _getStatusInfo(book.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusInfo['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo['icon'], color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            statusInfo['text'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // 진행률 카드
  Widget _buildProgressCard(BuildContext context, Book book, WidgetRef ref) {
    final progress = book.totalPages > 0
        ? book.currentPage / book.totalPages
        : 0.0;
    final progressPercent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행률 바 (드래그 가능)
          GestureDetector(
            onTapDown: (details) => _updateProgressFromPosition(
              context,
              details.localPosition.dx,
              book,
              ref,
            ),
            onPanUpdate: (details) => _updateProgressFromPosition(
              context,
              details.localPosition.dx,
              book,
              ref,
            ),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // 진행률 표시
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // 드래그 핸들
                    Positioned(
                      left:
                          (MediaQuery.of(context).size.width - 32) * progress -
                          8,
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          _isEditMode
              ? Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _currentPageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '현재 페이지',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '/',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _totalPagesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '총 페이지',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${book.currentPage} / ${book.totalPages} 페이지',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // 독서 기간 섹션
  Widget _buildReadingPeriodCard(BuildContext context, Book book) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                '독서 기간',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (book.startedAt != null || book.completedAt != null) ...[
            if (book.startedAt != null) ...[
              _buildDateRow(context, Icons.play_arrow, '시작일', book.startedAt!),
              const SizedBox(height: 12),
            ],
            if (book.completedAt != null) ...[
              _buildDateRow(
                context,
                Icons.check_circle,
                '완료일',
                book.completedAt!,
              ),
            ],
          ] else ...[
            Text(
              '독서 기간이 설정되지 않았습니다',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    IconData icon,
    String label,
    DateTime date,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          '${date.year}년 ${date.month}월 ${date.day}일',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // 메모/리뷰 섹션
  Widget _buildMemoCard(BuildContext context, Book book) {
    final hasMemo = book.memo != null && book.memo!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                '나의 메모',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isEditMode
              ? TextFormField(
                  controller: _memoController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '메모',
                    hintText: '이 책에 대한 생각을 자유롭게 기록해보세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.purple,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.purple.withOpacity(0.05),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasMemo
                        ? Colors.purple.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasMemo
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    hasMemo
                        ? book.memo!
                        : '아직 작성된 메모가 없습니다.\n이 책에 대한 생각을 기록해보세요! 📝',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: hasMemo ? Colors.black87 : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // 독서 노트 섹션
  Widget _buildNotesCard(BuildContext context, WidgetRef ref, Book book) {
    final hasNotes = book.notes.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_add, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '책갈피 (${book.notes.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                onPressed: () {
                  context.push('/reading-note/${book.id}');
                },
                tooltip: '새 노트 작성',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasNotes) ...[
            // 노트 목록 표시
            ...book.notes
                .take(3)
                .map((note) => _buildNotePreview(context, ref, book.id, note)),
            if (book.notes.length > 3)
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: 전체 노트 목록 화면으로 이동
                  },
                  child: Text('+ ${book.notes.length - 3}개 더 보기'),
                ),
              ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 작성된 노트가 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이 책에 대한 생각을 기록해보세요!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotePreview(
    BuildContext context,
    WidgetRef ref,
    String noteBookId,
    ReadingNote note,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/reading-note/$noteBookId', extra: note);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.pageNumber != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'p.${note.pageNumber}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/reading-note/$noteBookId', extra: note);
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('노트 삭제'),
                          content: const Text('정말 이 노트를 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        try {
                          await ref.read(deleteReadingNoteProvider)(
                            noteBookId,
                            note.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('노트가 삭제되었습니다')),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: $error')),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(note.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Map<String, dynamic> _getStatusInfo(BookStatus status) {
    switch (status) {
      case BookStatus.planned:
        return {
          'text': '읽을 예정',
          'icon': Icons.schedule,
          'color': AppColors.readingStatusPlanned,
        };
      case BookStatus.reading:
        return {
          'text': '읽는 중',
          'icon': Icons.auto_stories,
          'color': AppColors.readingStatusReading,
        };
      case BookStatus.completed:
        return {
          'text': '완독',
          'icon': Icons.check_circle,
          'color': AppColors.readingStatusCompleted,
        };
      case BookStatus.paused:
        return {
          'text': '읽기 중지',
          'icon': Icons.pause_circle,
          'color': AppColors.readingStatusPaused,
        };
    }
  }

  // 진행률 바 드래그/탭으로 진행률 업데이트
  void _updateProgressFromPosition(
    BuildContext context,
    double localX,
    Book book,
    WidgetRef ref,
  ) {
    // 진행률 바의 실제 너비 계산 (패딩 제외)
    final screenWidth = MediaQuery.of(context).size.width;
    final progressBarWidth = screenWidth - 32; // 좌우 마진 16씩 제거

    // 새로운 진행률 계산 (0.0 ~ 1.0)
    double newProgress = (localX / progressBarWidth).clamp(0.0, 1.0);

    // 새로운 현재 페이지 계산
    int newCurrentPage = (newProgress * book.totalPages).round();
    newCurrentPage = newCurrentPage.clamp(0, book.totalPages);

    // 책 정보 업데이트
    if (newCurrentPage != book.currentPage) {
      final updatedBook = book.copyWith(
        currentPage: newCurrentPage,
        updatedAt: DateTime.now(),
        status: newCurrentPage >= book.totalPages
            ? BookStatus.completed
            : (newCurrentPage > 0 ? BookStatus.reading : book.status),
      );

      // Provider를 통해 책 정보 업데이트
      ref.read(updateBookProvider)(updatedBook);

      // Debounced 피드백 제공
      _debouncedShowProgressUpdateFeedback(
        context,
        newCurrentPage,
        book.totalPages,
      );
    }
  }

  // Debounced 진행률 업데이트 피드백 표시
  void _debouncedShowProgressUpdateFeedback(
    BuildContext context,
    int currentPage,
    int totalPages,
  ) {
    // 기존 타이머가 있다면 취소
    _debounceTimer?.cancel();

    // 새로운 타이머 설정 (1초 후 실행)
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _showProgressUpdateFeedback(context, currentPage, totalPages);
      }
    });
  }

  // 진행률 업데이트 피드백 표시
  void _showProgressUpdateFeedback(
    BuildContext context,
    int currentPage,
    int totalPages,
  ) {
    final progressPercent = totalPages > 0
        ? ((currentPage / totalPages) * 100).round()
        : 0;

    // 기존 SnackBar 숨기기
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_stories, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '진행률이 $progressPercent% ($currentPage/$totalPages 페이지)로 업데이트되었습니다',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 편집 모드 진입
  void _enterEditMode() {
    final booksAsyncValue = ref.read(booksProvider);
    booksAsyncValue.whenData((books) {
      try {
        final book = books.firstWhere((book) => book.id == widget.bookId);
        _initializeControllers(book);
        setState(() {
          _isEditMode = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('책 정보를 불러올 수 없습니다')));
      }
    });
  }

  // 컨트롤러 초기화
  void _initializeControllers(Book book) {
    _titleController = TextEditingController(text: book.title);
    _authorController = TextEditingController(text: book.author);
    _totalPagesController = TextEditingController(
      text: book.totalPages.toString(),
    );
    _currentPageController = TextEditingController(
      text: book.currentPage.toString(),
    );
    _memoController = TextEditingController(text: book.memo ?? '');
    _coverImageUrlController = TextEditingController(text: book.coverImageUrl);

    _selectedStatus = book.status;
    _isFavorite = book.isFavorite;
    _priority = book.priority;
  }

  // 편집 취소
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
    });
    // 컨트롤러들 정리
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _memoController.dispose();
    _coverImageUrlController.dispose();
  }

  // 즐겨찾기 상태 즉시 업데이트
  Future<void> _updateFavoriteStatus() async {
    try {
      final booksAsyncValue = ref.read(booksProvider);
      await booksAsyncValue.when(
        data: (books) async {
          final book = books.firstWhere((book) => book.id == widget.bookId);

          final updatedBook = book.copyWith(
            isFavorite: _isFavorite,
            updatedAt: DateTime.now(),
          );

          await ref.read(updateBookProvider)(updatedBook);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(_isFavorite ? '즐겨찾기에 추가되었습니다' : '즐겨찾기에서 제거되었습니다'),
                  ],
                ),
                backgroundColor: _isFavorite ? Colors.amber : Colors.grey,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        loading: () {},
        error: (error, stack) {
          // 에러 발생 시 상태 되돌리기
          setState(() {
            _isFavorite = !_isFavorite;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('즐겨찾기 업데이트 실패: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (error) {
      // 에러 발생 시 상태 되돌리기
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('즐겨찾기 업데이트 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 변경사항 저장
  Future<void> _saveChanges() async {
    try {
      final booksAsyncValue = ref.read(booksProvider);
      await booksAsyncValue.when(
        data: (books) async {
          final book = books.firstWhere((book) => book.id == widget.bookId);

          final updatedBook = book.copyWith(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            totalPages: int.parse(_totalPagesController.text.trim()),
            currentPage: int.parse(_currentPageController.text.trim()),
            memo: _memoController.text.trim().isEmpty
                ? null
                : _memoController.text.trim(),
            coverImageUrl: _coverImageUrlController.text.trim(),
            status: _selectedStatus,
            isFavorite: _isFavorite,
            priority: _priority,
            updatedAt: DateTime.now(),
          );

          await ref.read(updateBookProvider)(updatedBook);

          setState(() {
            _isEditMode = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('책 정보가 수정되었습니다'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        loading: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('데이터를 불러오는 중입니다')));
        },
        error: (error, stack) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('오류: $error')));
        },
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('저장 실패: ${error.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

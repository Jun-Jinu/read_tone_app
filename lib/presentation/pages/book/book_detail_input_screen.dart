import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/reading_note.dart';
import '../../providers/book_provider.dart';
import '../../providers/image_provider.dart';
import '../../providers/book_search_provider.dart'
    show aladinBookApiServiceProvider;

class BookDetailInputScreen extends ConsumerStatefulWidget {
  final Book selectedBook;

  const BookDetailInputScreen({super.key, required this.selectedBook});

  @override
  ConsumerState<BookDetailInputScreen> createState() =>
      _BookDetailInputScreenState();
}

class _BookDetailInputScreenState extends ConsumerState<BookDetailInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _currentPageController = TextEditingController();
  final _memoController = TextEditingController();

  BookStatus _selectedStatus = BookStatus.planned;
  int _priority = 0;
  bool _isFavorite = false;
  bool _isLoading = false;
  String? _localImagePath; // 로컬에 저장된 이미지 경로
  String? _aladinDescription; // 알라딘 소개 텍스트

  // 스크롤 유도용 키
  final GlobalKey _scrollKeyBaseInfo = GlobalKey();
  final GlobalKey _scrollKeyStatus = GlobalKey();
  final GlobalKey _scrollKeyMemo = GlobalKey();

  // 독서 노트 관련 상태
  List<ReadingNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _downloadImageIfNeeded();
    _enrichFromAladinIfPossible();
  }

  bool _areBaseFieldsValid() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final pages = int.tryParse(_totalPagesController.text.trim());
    if (title.isEmpty || author.isEmpty) return false;
    if (pages == null || pages <= 0) return false;
    return true;
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  Widget _buildStatusSelector() {
    return Container(
      key: _scrollKeyStatus,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '독서 상태',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: BookStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return GestureDetector(
                onTap: () {
                  final baseOk = _areBaseFieldsValid();
                  if (!baseOk) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목/저자/총 페이지를 먼저 입력해주세요')),
                    );
                    _scrollTo(_scrollKeyBaseInfo);
                    return;
                  }

                  setState(() {
                    _selectedStatus = status;
                    if (!(_selectedStatus == BookStatus.reading ||
                        _selectedStatus == BookStatus.paused)) {
                      _currentPageController.text = '0';
                    }
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_selectedStatus == BookStatus.reading ||
                        _selectedStatus == BookStatus.paused) {
                      _scrollTo(_scrollKeyBaseInfo); // 아래 필드에 포함되므로 기본정보 섹션으로
                    } else {
                      _scrollTo(_scrollKeyMemo);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _initializeFields() {
    _titleController.text = widget.selectedBook.title;
    _authorController.text = widget.selectedBook.author;
    _totalPagesController.text = widget.selectedBook.totalPages.toString();
    _currentPageController.text = widget.selectedBook.currentPage.toString();
    _memoController.text = widget.selectedBook.memo ?? '';
    _selectedStatus = widget.selectedBook.status;
    _priority = widget.selectedBook.priority;
    _isFavorite = widget.selectedBook.isFavorite;
    _notes = List.from(widget.selectedBook.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: null,
          ),
        ),
        title: Text(
          '책 추가',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () {
                _isLoading ? null : _saveBook();
              },
              child: Text(
                '저장',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            120,
            16,
            16,
          ), // Top padding for AppBar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 표지 및 기본 정보
              _buildBookPreview(),
              const SizedBox(height: 32),

              // 독서 상태 선택 (상단 배치)
              _buildStatusSelector(),
              const SizedBox(height: 24),

              // 메모
              _buildMemoSection(),
              const SizedBox(height: 24),

              // 독서 노트
              if (_selectedStatus != BookStatus.planned) _buildNotesSection(),
              const SizedBox(height: 32),

              // 저장 버튼
              _buildSaveButton(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 책 표지 중앙 배치
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildBookCover(),
              ),
            ),
            const SizedBox(height: 24),

            // 책 정보 입력 (상단 편집 영역) + i 아이콘
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    key: _scrollKeyBaseInfo,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernTextField(
                        controller: _titleController,
                        label: '책 제목',
                        hint: '책 제목을 입력하세요',
                        icon: Icons.book_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '책 제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _authorController,
                        label: '저자',
                        hint: '저자명을 입력하세요',
                        icon: Icons.person_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '저자명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _totalPagesController,
                              label: '총 페이지',
                              hint: '0',
                              icon: Icons.layers_rounded,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '총 페이지를 입력해주세요';
                                }
                                final pages = int.tryParse(value);
                                if (pages == null || pages <= 0) {
                                  return '올바른 페이지 수를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_selectedStatus == BookStatus.reading ||
                              _selectedStatus == BookStatus.paused)
                            Expanded(
                              child: _buildModernTextField(
                                controller: _currentPageController,
                                label: '현재 페이지',
                                hint: '0',
                                icon: Icons.bookmark_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '현재 페이지를 입력해주세요';
                                  }
                                  final currentPage = int.tryParse(value);
                                  final totalPages = int.tryParse(
                                    _totalPagesController.text,
                                  );
                                  if (currentPage == null || currentPage < 0) {
                                    return '올바른 페이지 수를 입력해주세요';
                                  }
                                  if (totalPages != null &&
                                      currentPage > totalPages) {
                                    return '총 페이지보다 클 수 없습니다';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_aladinDescription != null &&
                    _aladinDescription!.trim().isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.purple.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _showBookIntroDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.info_rounded,
                            color: Colors.blue.shade600,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 하단 책 정보 폼 제거 (상단으로 이동)

  Widget _buildMemoSection() {
    return Container(
      key: _scrollKeyMemo,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.orange.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.amber],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '메모',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildModernTextField(
            controller: _memoController,
            label: '메모',
            hint: '이 책에 대한 메모를 입력하세요 (선택사항)',
            icon: Icons.sticky_note_2_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Future<void> _enrichFromAladinIfPossible() async {
    // ISBN13: 숫자만 추출 후 13자리인지 확인
    final cleaned = widget.selectedBook.id.replaceAll(RegExp(r'[^0-9]'), '');
    final isIsbn13 = RegExp(r'^\d{13}$').hasMatch(cleaned);
    if (!isIsbn13) return;

    try {
      final api = ref.read(aladinBookApiServiceProvider);
      final detail = await api.lookupByIsbn13(cleaned);
      if (!mounted) return;
      if (detail != null) {
        setState(() {
          if (detail.pageCount != null && detail.pageCount! > 0) {
            _totalPagesController.text = detail.pageCount!.toString();
          }
          _aladinDescription = detail.description;
        });
      }
    } catch (e) {
      // 네트워크 실패는 조용히 무시
      debugPrint('알라딘 상세 조회 실패: $e');
    }
  }

  /// 모던 텍스트 필드 위젯
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// 책 소개 다이얼로그
  void _showBookIntroDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.withOpacity(0.02)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '책 소개',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 내용
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          _aladinDescription ?? '소개 정보가 없습니다.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                height: 1.6,
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '출처: 알라딘 DB',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.note_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '독서 노트',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.cyan.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _addNote,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '노트 추가',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_notes.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade50, Colors.blue.withOpacity(0.02)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      size: 48,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 작성된 노트가 없습니다',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '노트를 추가해서 책에 대한 생각을 기록해보세요!',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteItem(note, index);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isLoading ? null : _saveBook,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '저장 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.library_add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '라이브러리에 추가',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(BookStatus status) {
    switch (status) {
      case BookStatus.planned:
        return '읽을 예정';
      case BookStatus.reading:
        return '읽는 중';
      case BookStatus.completed:
        return '완독';
      case BookStatus.paused:
        return '읽기 중지';
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 입력된 정보로 책 객체 업데이트
      // 상태에 따른 현재 페이지 보정
      final int totalPages = int.parse(_totalPagesController.text);
      final int adjustedCurrentPage =
          (_selectedStatus == BookStatus.reading ||
              _selectedStatus == BookStatus.paused)
          ? int.parse(_currentPageController.text)
          : 0;

      final updatedBook = widget.selectedBook.copyWith(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        totalPages: totalPages,
        currentPage: adjustedCurrentPage,
        status: _selectedStatus,
        priority: _priority,
        isFavorite: _isFavorite,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        notes: _notes,
        coverImageUrl:
            _localImagePath ??
            widget.selectedBook.coverImageUrl, // 로컬 경로 또는 원본 URL 사용
        updatedAt: DateTime.now(),
        startedAt: _selectedStatus == BookStatus.reading
            ? DateTime.now()
            : null,
        completedAt: _selectedStatus == BookStatus.completed
            ? DateTime.now()
            : null,
      );

      // 책을 라이브러리에 추가
      await ref.read(booksProvider.notifier).addBook(updatedBook);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedBook.title}이(가) 라이브러리에 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );

        // 이전 화면들로 돌아가기 (add_book_screen과 book_detail_input_screen 모두 닫기)
        context.pop(); // book_detail_input_screen 닫기
        context.pop(); // add_book_screen 닫기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('책 추가 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addNote() {
    _showNoteDialog();
  }

  void _showNoteDialog({ReadingNote? existingNote, int? index}) {
    final titleController = TextEditingController(
      text: existingNote?.title ?? '',
    );
    final contentController = TextEditingController(
      text: existingNote?.content ?? '',
    );
    final pageController = TextEditingController(
      text: existingNote?.pageNumber?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? '새 노트 추가' : '노트 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '노트 제목',
                  hintText: '노트 제목을 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '페이지 번호 (선택사항)',
                  hintText: '페이지 번호를 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '내용',
                  hintText: '노트 내용을 입력하세요',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('제목과 내용을 모두 입력해주세요'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final pageNumber = pageController.text.trim().isEmpty
                  ? null
                  : int.tryParse(pageController.text.trim());

              final note = ReadingNote(
                id:
                    existingNote?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                content: content,
                pageNumber: pageNumber,
                createdAt: existingNote?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              setState(() {
                if (existingNote == null) {
                  _notes.add(note);
                } else if (index != null) {
                  _notes[index] = note;
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    existingNote == null ? '노트가 추가되었습니다' : '노트가 수정되었습니다',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(existingNote == null ? '추가' : '수정'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(ReadingNote note, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.cyan.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sticky_note_2_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (note.pageNumber != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.amber],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    'p.${note.pageNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showNoteDialog(existingNote: note, index: index);
                    } else if (value == 'delete') {
                      _deleteNote(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 12),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              note.content,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 14,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(note.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 삭제'),
        content: const Text('정말 이 노트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('노트가 삭제되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 온라인 이미지를 로컬로 다운로드
  Future<void> _downloadImageIfNeeded() async {
    if (widget.selectedBook.coverImageUrl.isNotEmpty &&
        widget.selectedBook.coverImageUrl.startsWith('http')) {
      try {
        final imageManager = ref.read(imageManagerProvider);
        final localPath = await imageManager.downloadImageFromUrl(
          widget.selectedBook.coverImageUrl,
        );

        if (mounted) {
          setState(() {
            _localImagePath = localPath;
          });
        }
      } catch (e) {
        // 다운로드 실패 시 원본 URL 사용
        debugPrint('이미지 다운로드 실패: $e');
      }
    }
  }

  /// 책 표지 이미지 위젯 생성
  Widget _buildBookCover() {
    // 로컬 이미지가 있으면 로컬 이미지 사용
    if (_localImagePath != null && _localImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_localImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultBookIcon();
          },
        ),
      );
    }

    // 원본 URL이 있으면 네트워크 이미지 사용
    if (widget.selectedBook.coverImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.selectedBook.coverImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultBookIcon();
          },
        ),
      );
    }

    // 기본 아이콘 표시
    return _buildDefaultBookIcon();
  }

  /// 기본 책 아이콘 위젯
  Widget _buildDefaultBookIcon() {
    return const Center(child: Icon(Icons.book, size: 40));
  }
}

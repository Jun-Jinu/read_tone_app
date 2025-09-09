import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/book_provider.dart';
import 'package:read_tone_app/domain/entities/book.dart';

class LibraryAllBooksScreen extends ConsumerStatefulWidget {
  const LibraryAllBooksScreen({super.key});

  @override
  ConsumerState<LibraryAllBooksScreen> createState() =>
      _LibraryAllBooksScreenState();
}

class _LibraryAllBooksScreenState extends ConsumerState<LibraryAllBooksScreen> {
  String _selectedFilter = '전체';
  final List<Map<String, dynamic>> _filters = [
    {
      'name': '전체',
      'icon': Icons.library_books_rounded,
      'color': AppColors.primary,
    },
    {
      'name': '완독',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.readingStatusCompleted,
    },
    {
      'name': '읽고 있음',
      'icon': Icons.auto_stories_rounded,
      'color': AppColors.readingStatusReading,
    },
    {
      'name': '읽을 예정',
      'icon': Icons.bookmark_rounded,
      'color': AppColors.readingStatusPlanned,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final booksAsyncValue = ref.watch(booksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: booksAsyncValue.when(
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(context, error),
                data: (books) => _buildContent(context, books),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '모든 책',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(height: 24),
          const Text(
            '책들을 불러오는 중...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              '앗! 문제가 생겼어요',
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(booksProvider.notifier).refreshBooks(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Book> books) {
    final filteredBooks = _getFilteredBooks(books);

    return Column(
      children: [
        _buildFilterSection(context, books),
        Expanded(
          child: filteredBooks.isEmpty
              ? _buildEmptyState(context)
              : _buildBooksList(context, filteredBooks),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, List<Book> books) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter['name'];
            final count = _getFilterCount(books, filter['name']);

            return Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter['name'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? filter['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? filter['color'].withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'],
                        size: 20,
                        color: isSelected ? Colors.white : filter['color'],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : filter['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.3)
                                : filter['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : filter['color'],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📖', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == '전체' ? '아직 책이 없어요' : '$_selectedFilter 책이 없어요',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == '전체' ? '첫 번째 책을 추가해보세요!' : '다른 카테고리를 확인해보세요',
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

  Widget _buildBooksList(BuildContext context, List<Book> books) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(context, book);
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  _buildStatusBadge(context, book),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Book book) {
    Color color;
    String text;
    IconData icon;

    switch (book.status) {
      case BookStatus.planned:
        color = AppColors.readingStatusPlanned;
        text = '읽을 예정';
        icon = Icons.bookmark_rounded;
        break;
      case BookStatus.reading:
        color = AppColors.readingStatusReading;
        text = '${book.currentPage}/${book.totalPages} 페이지';
        icon = Icons.auto_stories_rounded;
        break;
      case BookStatus.completed:
        color = AppColors.readingStatusCompleted;
        text = '완독';
        icon = Icons.check_circle_rounded;
        break;
      case BookStatus.paused:
        color = AppColors.readingStatusPaused;
        text = '읽기 중지';
        icon = Icons.pause_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getFilterCount(List<Book> books, String filter) {
    switch (filter) {
      case '읽을 예정':
        return books.where((book) => book.status == BookStatus.planned).length;
      case '읽고 있음':
        return books.where((book) => book.status == BookStatus.reading).length;
      case '완독':
        return books
            .where((book) => book.status == BookStatus.completed)
            .length;
      default:
        return books.length;
    }
  }

  List<Book> _getFilteredBooks(List<Book> books) {
    switch (_selectedFilter) {
      case '읽을 예정':
        return books
            .where((book) => book.status == BookStatus.planned)
            .toList();
      case '읽고 있음':
        return books
            .where((book) => book.status == BookStatus.reading)
            .toList();
      case '완독':
        return books
            .where((book) => book.status == BookStatus.completed)
            .toList();
      default:
        return books;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/book_provider.dart';
import '../../../domain/entities/book.dart';

class StatisticsShareScreen extends ConsumerWidget {
  const StatisticsShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksProvider);

    return booksAsyncValue.when(
      data: (books) {
        final completedBooks =
            books.where((book) => book.status == BookStatus.completed).toList();
        final totalPages =
            completedBooks.fold<int>(0, (sum, book) => sum + book.totalPages);
        final averagePages =
            completedBooks.isEmpty ? 0 : totalPages ~/ completedBooks.length;

        return _buildContent(context, completedBooks, totalPages, averagePages);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Book> completedBooks,
      int totalPages, int averagePages) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계 공유'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 독서 통계',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '독서 활동을 공유해보세요.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildShareStatItem(
                        context,
                        '완독한 책',
                        '${completedBooks.length}권',
                        Icons.book,
                      ),
                      const Divider(height: 32),
                      _buildShareStatItem(
                        context,
                        '총 페이지',
                        '${totalPages}페이지',
                        Icons.menu_book,
                      ),
                      const Divider(height: 32),
                      _buildShareStatItem(
                        context,
                        '평균 페이지',
                        '${averagePages}페이지',
                        Icons.calculate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final shareText = '''
나의 독서 통계 📚

📖 완독한 책: ${completedBooks.length}권
📚 총 페이지: ${totalPages}페이지
📊 평균 페이지: ${averagePages}페이지

#독서 #독서통계 #독서습관
''';
                      Share.share(shareText);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('통계 공유하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

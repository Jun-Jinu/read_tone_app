import 'package:flutter/material.dart';
import '../../../widgets/common_text_styles.dart';

class BookInfoSection extends StatelessWidget {
  final String title;
  final String author;
  final String publisher;
  final String publishDate;
  final String? coverImageUrl;

  const BookInfoSection({
    super.key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publishDate,
    this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: coverImageUrl != null
                ? Image.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 60);
                    },
                  )
                : const Icon(Icons.book, size: 60),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextStyles.bookTitle(context, title),
                const SizedBox(height: 8),
                CommonTextStyles.bookAuthor(context, author),
                const SizedBox(height: 16),
                CommonTextStyles.bookInfo(context, publisher),
                const SizedBox(height: 8),
                CommonTextStyles.bookInfo(context, publishDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

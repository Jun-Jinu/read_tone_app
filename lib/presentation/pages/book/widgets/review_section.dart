import 'package:flutter/material.dart';
import '../../../widgets/common_text_styles.dart';

class ReviewSection extends StatelessWidget {
  final String review;

  const ReviewSection({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextStyles.sectionTitle(context, '감상문'),
          const SizedBox(height: 8),
          CommonTextStyles.sectionDescription(context, review),
        ],
      ),
    );
  }
}

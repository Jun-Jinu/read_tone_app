import 'package:flutter/material.dart';
import '../../../widgets/common_text_styles.dart';

class AdditionalNotesSection extends StatelessWidget {
  final String additionalNotes;

  const AdditionalNotesSection({
    super.key,
    required this.additionalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextStyles.sectionTitle(context, '추가 기록'),
          const SizedBox(height: 8),
          CommonTextStyles.sectionDescription(context, additionalNotes),
        ],
      ),
    );
  }
}

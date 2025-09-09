import 'package:flutter/material.dart';
import '../../../widgets/common_text_styles.dart';

class ReadingPeriodSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const ReadingPeriodSection({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextStyles.sectionTitle(context, '독서 기간'),
          const SizedBox(height: 8),
          CommonTextStyles.sectionDescription(
            context,
            _buildPeriodText(),
          ),
        ],
      ),
    );
  }

  String _buildPeriodText() {
    if (startDate == null && endDate == null) {
      return '독서 기간이 설정되지 않았습니다.';
    }

    final startText = startDate != null
        ? '${startDate!.year}년 ${startDate!.month}월 ${startDate!.day}일'
        : '시작일 미설정';

    final endText = endDate != null
        ? '${endDate!.year}년 ${endDate!.month}월 ${endDate!.day}일'
        : '종료일 미설정';

    return '$startText ~ $endText';
  }
}

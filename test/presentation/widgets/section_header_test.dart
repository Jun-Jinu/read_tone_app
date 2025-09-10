import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_tone_app/presentation/widgets/common/section_header.dart';

void main() {
  testWidgets('SectionHeader는 타이틀과 액션을 렌더링한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: '헤더',
            action: Icon(Icons.chevron_right, key: Key('actionIcon')),
          ),
        ),
      ),
    );

    expect(find.text('헤더'), findsOneWidget);
    expect(find.byKey(const Key('actionIcon')), findsOneWidget);
  });
}

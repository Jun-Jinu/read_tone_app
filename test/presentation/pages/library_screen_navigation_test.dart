import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:read_tone_app/presentation/pages/library/library_screen.dart';

void main() {
  testWidgets('LibraryScreen: "모든 책" 헤더 우측 아이콘 탭 시 /library/all 로 이동', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LibraryScreen(),
          routes: [
            GoRoute(
              path: 'library/all',
              builder: (context, state) => const Scaffold(body: Text('ALL')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // 아이콘 탐색 (arrow_forward_ios)
    final iconFinder = find.byIcon(Icons.arrow_forward_ios);
    expect(iconFinder, findsWidgets);

    await tester.tap(iconFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('ALL'), findsOneWidget);
  });
}

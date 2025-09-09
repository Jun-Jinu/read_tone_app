import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:read_tone_app/core/constants/app_constants.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  static const _navigationItems = [
    (path: AppConstants.homeRoute, icon: Icons.home, label: '홈'),
    (path: AppConstants.searchRoute, icon: Icons.search, label: '검색'),
    (path: AppConstants.libraryRoute, icon: Icons.library_books, label: '서재'),
    (path: AppConstants.statisticsRoute, icon: Icons.bar_chart, label: '통계'),
    (path: AppConstants.myPageRoute, icon: Icons.person, label: '마이'),
  ];

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              return TextStyle(
                color: states.contains(WidgetState.selected)
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.go(_navigationItems[index].path),
          elevation: 0,
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          backgroundColor: colorScheme.surface,
          destinations: _buildNavigationDestinations(colorScheme),
        ),
      ),
    );
  }

  List<NavigationDestination> _buildNavigationDestinations(
    ColorScheme colorScheme,
  ) {
    return _navigationItems.map((item) {
      return NavigationDestination(
        icon: Icon(
          item.icon,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        selectedIcon: Icon(item.icon, color: colorScheme.onSurface),
        label: item.label,
      );
    }).toList();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    final index = _navigationItems.indexWhere(
      (item) => path.startsWith(item.path),
    );
    // 매치되지 않으면 홈(2번 인덱스)을 기본값으로 사용
    return index != -1 ? index : 2;
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_tone_app/core/constants/app_constants.dart';
import 'package:read_tone_app/presentation/pages/legal/terms_of_service_screen.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_note.dart';
import '../../presentation/layouts/main_layout.dart';
import '../../presentation/pages/auth/splash_screen.dart';
import '../../presentation/pages/auth/login_screen.dart';
import '../../presentation/pages/main/home_screen.dart';
import '../../presentation/pages/library/library_screen.dart';
import '../../presentation/pages/library/library_all_books_screen.dart';
import '../../presentation/pages/book/reading_session_screen.dart';
import '../../presentation/pages/book/book_detail_screen.dart';

import '../../presentation/pages/book/book_detail_input_screen.dart';
import '../../presentation/pages/book/reading_note_screen.dart';
import '../../presentation/pages/statistics/share_statistics_screen.dart';
import '../../presentation/pages/statistics/statistics_screen.dart';
import '../../presentation/pages/my_page/my_page_screen.dart';
import '../../presentation/pages/my_page/login_benefits_screen.dart';
import '../../presentation/pages/my_page/user_profile_edit_screen.dart';
import '../../presentation/pages/settings/theme_test_screen.dart';
import '../../presentation/pages/settings/settings_screen.dart';
import '../../presentation/pages/legal/privacy_policy_screen.dart';
import '../../presentation/pages/search/search_screen.dart';
import '../../presentation/providers/book_provider.dart';
import '../../presentation/providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) {
      final currentLocation = state.matchedLocation;

      debugPrint('Router redirect: currentLocation=$currentLocation');
      debugPrint('Router redirect: isLoading=${authState.isLoading}');
      debugPrint('Router redirect: isLoggedIn=${authState.isLoggedIn}');
      debugPrint('Router redirect: isGuest=${authState.isGuest}');
      debugPrint('Router redirect: error=${authState.error}');

      if (authState.isLoading) {
        if (currentLocation != AppConstants.splashRoute) {
          debugPrint('Router redirect: 로딩 중, 스플래시로 이동');
          return AppConstants.splashRoute;
        }
        return null;
      }

      if (!authState.isLoggedIn &&
          !authState.isGuest &&
          currentLocation != AppConstants.loginRoute &&
          currentLocation != AppConstants.splashRoute) {
        debugPrint('Router redirect: 미인증 상태, 로그인으로 이동');
        return AppConstants.loginRoute;
      }

      if (authState.isLoggedIn &&
          (currentLocation == AppConstants.loginRoute ||
              currentLocation == AppConstants.splashRoute)) {
        debugPrint('Router redirect: 로그인됨, 홈으로 이동');
        return AppConstants.homeRoute;
      }

      if (authState.isGuest &&
          (currentLocation == AppConstants.splashRoute ||
              currentLocation == AppConstants.loginRoute)) {
        debugPrint('Router redirect: 비회원, 홈으로 이동');
        return AppConstants.homeRoute;
      }

      debugPrint('Router redirect: 리다이렉트 없음');
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.libraryRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: AppConstants.libraryAllRoute,
            builder: (context, state) => const LibraryAllBooksScreen(),
          ),
          GoRoute(
            path: AppConstants.searchRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: AppConstants.homeRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppConstants.statisticsRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatisticsScreen()),
          ),
          GoRoute(
            path: AppConstants.myPageRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyPageScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '${AppConstants.readingSessionRoute}/:id',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          final booksAsyncValue = ref.read(booksProvider);

          return booksAsyncValue.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('책을 찾을 수 없습니다: $error'),
                  ],
                ),
              ),
            ),
            data: (books) {
              try {
                final book = books.firstWhere((book) => book.id == bookId);
                return ReadingSessionScreen(book: book);
              } catch (e) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.book_outlined, size: 64),
                        const SizedBox(height: 16),
                        Text(AppConstants.errorBookNotFound),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      GoRoute(
        path: '${AppConstants.bookDetailRoute}/:id',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          final startEdit = state.uri.queryParameters['edit'] == 'true';
          return BookDetailScreen(bookId: bookId, startInEditMode: startEdit);
        },
      ),
      GoRoute(
        path: AppConstants.bookDetailInputRoute,
        builder: (context, state) {
          final book = state.extra as Book?;
          if (book == null) {
            return const Scaffold(body: Center(child: Text('잘못된 접근입니다.')));
          }
          return BookDetailInputScreen(selectedBook: book);
        },
      ),
      GoRoute(
        path: '/reading-note/:bookId',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          final note = state.extra as ReadingNote?;

          return ReadingNoteScreen(bookId: bookId, note: note);
        },
      ),
      GoRoute(
        path: AppConstants.statisticsShareRoute,
        builder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'];
          final isBookSpecific =
              state.uri.queryParameters['isBookSpecific'] == 'true';

          return ShareStatisticsScreen(
            bookId: bookId,
            isBookSpecific: isBookSpecific,
          );
        },
      ),
      GoRoute(
        path: AppConstants.privacyPolicyRoute,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppConstants.termsOfServiceRoute,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: AppConstants.themeTestRoute,
        builder: (context, state) => const ThemeTestScreen(),
      ),
      GoRoute(
        path: AppConstants.searchRoute,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/login-benefits',
        builder: (context, state) => const LoginBenefitsScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const UserProfileEditScreen(),
      ),
    ],
  );
});

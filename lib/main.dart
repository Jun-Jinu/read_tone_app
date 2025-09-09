import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/database_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'data/services/firebase_firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('앱 시작: Firebase 초기화 중...');

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase 초기화 완료');

    // Firestore 오프라인 지원 활성화 (선택사항)
    if (!kIsWeb) {
      final firestoreService = FirebaseFirestoreService();
      await firestoreService.enableOfflineSupport();
      debugPrint('Firestore 오프라인 지원 활성화 완료');
    }
  } catch (e) {
    debugPrint('❌ Firebase 초기화 실패: $e');
  }

  // .env 파일 로드 (파일이 없으면 무시)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('.env 파일 로드 완료');
  } catch (e) {
    debugPrint('⚠️ .env 파일 로드 실패: $e (선택사항이므로 계속 진행)');
    // .env 파일이 없어도 계속 진행
  }

  // 웹이 아닌 플랫폼에서만 데이터베이스 초기화
  if (!kIsWeb) {
    try {
      await DatabaseService.database;
      debugPrint('로컬 데이터베이스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 데이터베이스 초기화 오류: $e');
      // 웹에서는 오류 무시하고 계속 진행
    }
  }

  debugPrint('🚀 앱 시작 준비 완료');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(materialThemeModeProvider);

    return MaterialApp.router(
      title: 'readtone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: themeMode,
      routerConfig: router,
    );
  }
}

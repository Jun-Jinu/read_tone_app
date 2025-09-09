import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  bool _hasNavigated = false;
  Timer? _safetyTimer;
  bool _minDelayElapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // 최소 2초 후에 네비게이션 가능하도록 설정
    _timer = Timer(const Duration(milliseconds: 2000), () {
      _minDelayElapsed = true;
      _checkAndNavigate();
    });

    // 안전 타임아웃: 6초가 지나도 로딩이면 로그인 화면으로 이동
    _safetyTimer = Timer(const Duration(seconds: 6), () {
      if (!_hasNavigated && mounted) {
        _hasNavigated = true;
        context.go('/login');
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  void _checkAndNavigate() {
    if (_hasNavigated) return;

    final authState = ref.read(authProvider);

    // 최소 대기시간이 경과하고 로딩이 완료된 후에만 네비게이션
    if (_minDelayElapsed && !authState.isLoading) {
      _hasNavigated = true;
      _safetyTimer?.cancel();

      if (authState.isLoggedIn) {
        // 로그인된 상태라면 홈으로
        context.go('/home');
      } else {
        // 로그인되지 않은 상태라면 로그인 화면으로
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _safetyTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 인증 상태 변화를 감지하여 네비게이션 (build에서만 사용 가능)
    ref.listen(authProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndNavigate();
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Image.asset('assets/images/logo/readtone.png'),
                    const SizedBox(height: 8),
                    Text(
                      'Read in your tone.',
                      // '당신의 리듬으로 읽고, 기록하세요.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 48),
                    // 로딩 인디케이터와 상태 메시지
                    Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authState.isLoading ? '앱을 초기화하는 중...' : '시작 준비 완료!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

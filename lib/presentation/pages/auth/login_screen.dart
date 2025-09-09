import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _emailController.dispose();
      _passwordController.dispose();
    } catch (e) {
      debugPrint('컨트롤러 dispose 중 에러: $e');
    }
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _safeClearController(TextEditingController controller) {
    if (!_isDisposed && mounted) {
      try {
        controller.clear();
      } catch (e) {
        debugPrint('컨트롤러 clear 중 에러: $e');
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    _safeSetState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // 로그인 성공 시 필드 초기화 (mounted 체크)
      if (mounted) {
        try {
          _safeClearController(_emailController);
          _safeClearController(_passwordController);
        } catch (e) {
          debugPrint('컨트롤러 초기화 중 에러: $e');
        }
      }

      // GoRouter를 사용하여 홈으로 이동 (리다이렉트가 자동으로 처리됨)
      // 추가 네비게이션은 필요 없음 - 라우터가 자동으로 처리
    } catch (e) {
      // 로그인 실패 시 비밀번호 필드만 초기화 (mounted 체크)
      if (mounted) {
        try {
          _safeClearController(_passwordController);
        } catch (clearError) {
          debugPrint('비밀번호 필드 초기화 중 에러: $clearError');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();

      // GoRouter를 사용하여 홈으로 이동 (리다이렉트가 자동으로 처리됨)
      // 추가 네비게이션은 필요 없음 - 라우터가 자동으로 처리
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    debugPrint('LoginScreen: 비회원 로그인 시작');
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      debugPrint('LoginScreen: continueAsGuest 호출');
      await ref.read(authProvider.notifier).continueAsGuest();

      debugPrint('LoginScreen: continueAsGuest 완료, 홈으로 이동');
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('LoginScreen: 비회원 로그인 실패 - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignup() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 재설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('재설정 링크를 받을 이메일 주소를 입력해주세요.'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              hintText: '이메일',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return '올바른 이메일 형식을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                try {
                  await ref
                      .read(authProvider.notifier)
                      .sendPasswordResetEmail(emailController.text.trim());

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '비밀번호 재설정 이메일을 발송했습니다. 이메일을 확인해주세요.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 및 제목
                Column(
                  children: [
                    Image.asset('assets/images/logo/readtone.png'),
                    // const SizedBox(height: 8),
                    Text(
                      '나만의 톤으로 읽다.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 로그인 폼
                Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      hintText: '이메일',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return '올바른 이메일 형식을 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      hintText: '비밀번호',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _safeSetState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // 비밀번호 찾기
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          '비밀번호를 잊으셨나요?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 로그인 버튼
                    CustomButton(
                      text: '로그인',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 16),

                    // 구분선
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '또는',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 구글 로그인 버튼
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Google로 로그인'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 비회원 로그인 버튼
                    TextButton.icon(
                      onPressed: _isLoading ? null : _handleGuestLogin,
                      icon: const Icon(Icons.person_outline),
                      label: const Text('비회원으로 계속하기'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: Text(
                        '회원가입',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

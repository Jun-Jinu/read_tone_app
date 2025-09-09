import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class UserProfileEditScreen extends ConsumerStatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  ConsumerState<UserProfileEditScreen> createState() =>
      _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends ConsumerState<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  int _dailyReadingGoal = 30;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // didChangeDependencies에서 초기화하도록 변경
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeUserData();
      _isInitialized = true;
    }
  }

  void _initializeUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      setState(() {
        _displayNameController.text = user.displayName ?? '';
        _emailController.text = user.email;
        _bioController.text = user.bio ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _selectedBirthDate = user.birthDate;
        _notificationsEnabled = user.notificationsEnabled;
        _emailNotificationsEnabled = user.emailNotificationsEnabled;
        _dailyReadingGoal = user.dailyReadingGoal;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          displayName: _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : null,
          bio: _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          birthDate: _selectedBirthDate,
          notificationsEnabled: _notificationsEnabled,
          emailNotificationsEnabled: _emailNotificationsEnabled,
          dailyReadingGoal: _dailyReadingGoal,
          updatedAt: DateTime.now(),
        );

        await ref.read(authProvider.notifier).updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('프로필이 성공적으로 저장되었습니다.'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '프로필 저장 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 사용자 정보 변경을 실시간으로 감지
    final authState = ref.watch(authProvider);
    final currentUser = authState.user;

    // 사용자 정보가 변경되었을 때 필드를 업데이트
    if (currentUser != null && _isInitialized) {
      if (_displayNameController.text != (currentUser.displayName ?? '')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayNameController.text = currentUser.displayName ?? '';
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 편집'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              '저장',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 이미지 섹션
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 기본 정보 섹션
              Text(
                '기본 정보',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _displayNameController,
                labelText: '이름',
                hintText: '이름을 입력하세요',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                labelText: '이메일',
                hintText: '이메일 주소',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // 이메일은 수정 불가
              ),

              const SizedBox(height: 16),

              // CustomTextField(
              //   controller: _phoneController,
              //   labelText: '전화번호',
              //   hintText: '전화번호를 입력하세요',
              //   prefixIcon: Icons.phone_outlined,
              //   keyboardType: TextInputType.phone,
              // ),

              // const SizedBox(height: 16),

              // // 생년월일 선택
              // InkWell(
              //   onTap: _selectBirthDate,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: AppColors.border),
              //       borderRadius: BorderRadius.circular(12),
              //       color: AppColors.surface,
              //     ),
              //     child: Row(
              //       children: [
              //         const Icon(
              //           Icons.calendar_today_outlined,
              //           color: AppColors.textSecondary,
              //           size: 20,
              //         ),
              //         const SizedBox(width: 12),
              //         Expanded(
              //           child: Text(
              //             _selectedBirthDate != null
              //                 ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
              //                 : '생년월일을 선택하세요',
              //             style: AppTextStyles.bodyMedium.copyWith(
              //               color: _selectedBirthDate != null
              //                   ? AppColors.textPrimary
              //                   : AppColors.textSecondary,
              //             ),
              //           ),
              //         ),
              //         const Icon(
              //           Icons.arrow_forward_ios,
              //           color: AppColors.textSecondary,
              //           size: 16,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 32),

              // 저장 버튼
              CustomButton(
                text: '프로필 저장',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

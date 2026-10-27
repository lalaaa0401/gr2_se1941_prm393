import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../../core/app_strings.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();

  // Trạng thái hiển thị mật khẩu
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  String? _validate() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (fullName.isEmpty) return 'Họ và tên không được để trống';
    if (email.isEmpty) return 'Email không được để trống';

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) return 'Email không hợp lệ';

    if (password.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (password != confirm) return 'Mật khẩu xác nhận không khớp';

    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(
      _emailController.text.trim(),
      _passwordController.text,
      _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      school: _schoolController.text.trim().isNotEmpty ? _schoolController.text.trim() : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Chào mừng bạn đến QuizLab 🎉'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Đăng ký thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Style chung cho input field v5
  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceDim,
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textDisabled,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [A] Cream header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Q',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('QuizLab', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.splashTagline,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // [B] White bottom sheet
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Đăng ký', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.registerSubtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Họ và tên
                      TextField(
                        controller: _fullNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          hintText: AppStrings.fullName,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(hintText: AppStrings.email),
                      ),
                      const SizedBox(height: 16),

                      // Mật khẩu
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: _inputDecoration(
                          hintText: AppStrings.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Xác nhận mật khẩu
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        decoration: _inputDecoration(
                          hintText: 'Xác nhận mật khẩu',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible =
                                    !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Số điện thoại (optional)
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                            hintText: 'Số điện thoại (tuỳ chọn)'),
                      ),
                      const SizedBox(height: 16),

                      // Trường / Tổ chức (optional)
                      TextField(
                        controller: _schoolController,
                        decoration: _inputDecoration(
                            hintText: 'Trường / Tổ chức (tuỳ chọn)'),
                      ),
                      const SizedBox(height: 24),

                      // Button + error
                      Consumer<AuthViewModel>(
                        builder: (context, auth, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Đăng ký'),
                              ),
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Điều hướng sang đăng nhập
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text(
                          'Đã có tài khoản? Đăng nhập',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

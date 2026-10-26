import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      _showError('Vui lòng nhập họ tên');
      return;
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      _showError('Vui lòng nhập email hợp lệ');
      return;
    }
    if (password.length < 8) {
      _showError('Mật khẩu tối thiểu 8 ký tự');
      return;
    }
    if (password != confirmPassword) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(email, password, fullName);
    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.login);
    } else {
      _showError(authViewModel.errorMessage ?? 'Đăng ký thất bại');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle:
            const TextStyle(color: AppColors.textDisabled, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(_fullNameController, 'Họ và tên'),
              const SizedBox(height: 12),
              _buildTextField(
                _emailController,
                'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _passwordController,
                'Mật khẩu',
                obscureText: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _confirmPasswordController,
                'Xác nhận mật khẩu',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.01,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Đăng ký'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text(
                  'Đã có tài khoản? Đăng nhập',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

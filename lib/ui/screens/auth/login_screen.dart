import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../common/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'alex.explorer@arvision.app');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Alex Rivers');

  bool _isSignUp = false;
  String _selectedRole = 'consumer'; // 'consumer' or 'advertiser'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await auth.register(
        email: email,
        password: password,
        displayName: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
        role: _selectedRole,
      );
    } else {
      success = await auth.signIn(email, password);
      auth.switchRole(_selectedRole);
    }

    if (success && mounted) {
      if (_selectedRole == 'advertiser') {
        context.go('/advertiser');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Brand Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AR-AdVision',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Bring Everyday Ads to Life in AR',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Role Selector Tabs (Consumer vs Advertiser)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'consumer'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'consumer' ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedRole == 'consumer'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Explorer (Consumer)',
                              style: AppTypography.labelMedium.copyWith(
                                color: _selectedRole == 'consumer'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: _selectedRole == 'consumer'
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'advertiser'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'advertiser' ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedRole == 'advertiser'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Brand (Advertiser)',
                              style: AppTypography.labelMedium.copyWith(
                                color: _selectedRole == 'advertiser'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: _selectedRole == 'advertiser'
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Create Account' : 'Welcome Back',
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: 18),

                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: _isSignUp ? 'Sign Up & Start' : 'Sign In',
                      isLoading: auth.isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Guest Access Button
              TextButton.icon(
                onPressed: () {
                  auth.switchRole(_selectedRole);
                  if (_selectedRole == 'advertiser') {
                    context.go('/advertiser');
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                label: Text(
                  'Continue as Guest (${_selectedRole == 'advertiser' ? 'Advertiser' : 'Consumer'})',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 8),

              // Toggle Sign Up / Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                    style: AppTypography.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Sign In' : 'Sign Up',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

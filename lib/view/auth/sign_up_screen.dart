import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: getHeight(100)),

              // ── Heading ─────────────────────────────
              Text(
                AppText.welcomeBacktext,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(30),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: getHeight(8)),

              Text(
                AppText.signuotogetstarted,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD9D9D9),
                ),
              ),

              SizedBox(height: getHeight(48)),

              // ── Name Field ─────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: AppText.name,
                icon: null,
                obscure: false,
              ),

              SizedBox(height: getHeight(16)),

              // ── Email Field ─────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: AppText.emailOrPhone,
                icon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                obscure: _obscurePassword,
              ),

              SizedBox(height: getHeight(16)),

              // ── Password ───────────────────────────
              _buildTextField(
                controller: _passwordController,
                hint: AppText.passwordtext,
                icon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                obscure: _obscurePassword,
              ),

              SizedBox(height: getHeight(16)),

              // ── Confirm Password ────────────────────
              _buildTextField(
                controller: _passwordController,
                hint: AppText.confirmPassword,
                icon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                obscure: _obscurePassword,
              ),

              SizedBox(height: getHeight(32)),

              // ── Sign Up Button ─────────────────────
              _buildGradientButton(
                label: AppText.signUp,
                onTap: () {
                  context.push('/bottombar');
                },
              ),

              const SizedBox(height: 28),

              // ── Divider ────────────────────────────
              Row(
                children: [
                  Expanded(child: _divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppText.or,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20),
                      ),
                    ),
                  ),
                  Expanded(child: _divider()),
                ],
              ),

              SizedBox(height: getHeight(36)),

              // ── Footer ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.dontHaveAccount,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      AppText.signUp,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── TEXT FIELD ─────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    Widget? icon,
  }) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.fieldGradient,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.borderPurple,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(16),
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: icon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ── BUTTON ────────────────────────────────
  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.buttonGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonGradient[1].withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(20),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── DIVIDER ───────────────────────────────
  Widget _divider() => Container(
        height: 1,
        color: AppColors.divider,
      );
}
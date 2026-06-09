import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ─── Colors (match your screenshot) ───────────────────────────────────────
  
  static const Color _accent = Color(0xFF3B82F6);       // blue accent   // cyan
  static const Color _gradEnd = Color(0xFF3B82F6);      // blue
  static const Color _textHint = Color(0xFF6B7FAB);
  static const Color _white = Colors.white;

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

              // ── Heading ──────────────────────────────────────────────────
               Text(
                AppText.welcomeBack,
                textAlign: TextAlign.center,
                style:AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(30),
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                )
              ),
              const SizedBox(height: 8),
               Text(
                AppText.signContinue,
                textAlign: TextAlign.center,
                style:AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD9D9D9),
                )
              ),

              const SizedBox(height: 48),

              // ── Email / Phone Field ───────────────────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: AppText.emailorPhone,
                icon: null,
                obscure: false,
              ),

              const SizedBox(height: 16),

              // ── Password Field ────────────────────────────────────────────
              _buildTextField(
                controller: _passwordController,
                hint:AppText.password,
                icon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                obscure: _obscurePassword,
              ),

              const SizedBox(height: 12),

              // ── Forgot Password ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Log In Button ─────────────────────────────────────────────
              _buildGradientButton(
                label: 'Log in',
                onTap: () {
                 context.push('/signup');
                },
              ),

              const SizedBox(height: 28),

              // ── OR Divider ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _divider()),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20)
                      )
                    ),
                  ),
                  Expanded(child: _divider()),
                ],
              ),

              const SizedBox(height: 24),

              // ── Social Buttons ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      onTap: () {},
                      child:Image(image: AssetImage(AppImages.googlebattery))
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _socialButton(
                      onTap: () {},
                      child: const Icon(
                        Icons.apple,
                        color: _white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ── Sign Up Link ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child:  Text(
                      'Sign Up',
                     style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white
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

  // ── Helpers ──────────────────────────────────────────────────────────────

 Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required bool obscure,
  Widget? icon,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
     
    ),
    child: Container(
      margin: const EdgeInsets.all(1), // border effect
      decoration: BoxDecoration(
         gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1B235C), // top (lighter blue)
          Color(0xFF1B2153), // middle
          Color(0xFF13173A), // bottom (dark blue)
        ],
      ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Color(0xFF4103AC),
          width: 0.5
        )
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:AppTextStyles.bodySmall.copyWith(
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
    ),
  );
}

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(60),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF55D0FF),
               Color(0xFF0E5AA7),
               
               ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gradEnd.withOpacity(0.35),
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
          fontWeight:FontWeight.w700,
        ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1B235C), // top (lighter blue)
          Color(0xFF1B2153), // middle
          Color(0xFF13173A), // bottom (dark blue)
        ],
      ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A3F6F), width: 1),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: const Color(0xFF373C62),
      );
}
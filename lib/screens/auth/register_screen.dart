import 'package:flutter/material.dart';
import 'dart:math' as math;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _passwordsMatch = false;

static const _accent = Color(0xFFE8A87C); 
  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _confirmPasswordController.addListener(_checkPasswords);
    _passwordController.addListener(_checkPasswords);
  }

  void _checkPasswords() {
    final match = _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
    if (match != _passwordsMatch) {
      setState(() => _passwordsMatch = match);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141018),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: _BlobPainter(_bgController.value, _accent),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Brand
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.chevron_left_rounded,
                            color: _accent, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Whisker 🐾',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create your\naccount.',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Join Whisker and never miss a meal.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // First + Last name row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'FIRST NAME'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _firstNameController,
                            hint: 'First',
                            prefixIcon: Icons.person_outline_rounded,
                            accent: _accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'LAST NAME'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _lastNameController,
                            hint: 'Last',
                            prefixIcon: Icons.person_outline_rounded,
                            accent: _accent,
                            showPrefix: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                const _FieldLabel(label: 'EMAIL'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  accent: _accent,
                ),
                const SizedBox(height: 16),

                // Password
                const _FieldLabel(label: 'PASSWORD'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _passwordController,
                  hint: 'Min. 8 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  accent: _accent,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 16),

                // Confirm password
                const _FieldLabel(label: 'CONFIRM PASSWORD'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _confirmPasswordController,
                  hint: 'Repeat password',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.shield_outlined,
                  accent: _accent,
                  suffixIcon: _passwordsMatch
                      ? Icons.check_circle_rounded
                      : (_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                  suffixColor: _passwordsMatch ? Colors.greenAccent.shade400 : null,
                  onSuffixTap: _passwordsMatch
                      ? null
                      : () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 16),

                // Terms checkbox
                GestureDetector(
                  onTap: () =>
                      setState(() => _agreedToTerms = !_agreedToTerms),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? _accent.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _agreedToTerms
                                ? _accent
                                : Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: _agreedToTerms
                            ? Icon(Icons.check_rounded,
                                size: 12, color: _accent)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.35),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "I agree to Whisker's "),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                    color: _accent,
                                    fontWeight: FontWeight.w500),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: _accent,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Create account button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _agreedToTerms
                        ? () {
                            // TODO: handle registration
                          }
                        : null,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Create Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      disabledBackgroundColor: _accent.withOpacity(0.35),
                      foregroundColor: const Color(0xFF1A0F08),
                      disabledForegroundColor:
                          const Color(0xFF1A0F08).withOpacity(0.5),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Social row
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata_rounded,
                          onTap: () {}),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                          label: 'Apple',
                          icon: Icons.apple_rounded,
                          onTap: () {}),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Login redirect
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool showPrefix;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? suffixColor;
  final VoidCallback? onSuffixTap;
  final Color accent;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.accent,
    this.obscureText = false,
    this.showPrefix = true,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.suffixColor,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1825),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          prefixIcon: showPrefix
              ? Icon(prefixIcon, color: accent.withOpacity(0.6), size: 18)
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon,
                      color: suffixColor ?? Colors.white.withOpacity(0.3),
                      size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1825),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── Blob background ───────────────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  final double t;
  final Color accent;
  _BlobPainter(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF141018));
    final blobs = [
      _Blob(
          color: accent.withOpacity(0.14),
          cx: 0.20 + 0.08 * math.sin(2 * math.pi * t),
          cy: 0.25 + 0.08 * math.cos(2 * math.pi * t + 0.5),
          rx: 0.55,
          ry: 0.40),
      _Blob(
          color: accent.withOpacity(0.08),
          cx: 0.75 + 0.07 * math.cos(2 * math.pi * t + 1.2),
          cy: 0.55 + 0.10 * math.sin(2 * math.pi * t + 2.0),
          rx: 0.45,
          ry: 0.38),
    ];
    for (final blob in blobs) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(blob.cx * size.width, blob.cy * size.height),
          width: blob.rx * size.width,
          height: blob.ry * size.height,
        ),
        Paint()
          ..color = blob.color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t || old.accent != accent;
}

class _Blob {
  final Color color;
  final double cx, cy, rx, ry;
  const _Blob(
      {required this.color,
      required this.cx,
      required this.cy,
      required this.rx,
      required this.ry});
}
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final _emailController = TextEditingController();
  bool _sent = false;

  static const _accent = Color(0xFFE8A87C);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _sent = true);
    // TODO: call your auth service here
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
                              color: _accent.withOpacity(0.3), width: 1),
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
                const SizedBox(height: 40),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _accent.withOpacity(0.25), width: 1),
                  ),
                  child: Icon(Icons.lock_outline_rounded,
                      color: _accent, size: 32),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Forgot your\npassword?',
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
                  'No worries — enter your email and we\'ll send you a reset link right away.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),

                // Email field
                _sent ? _SuccessState(accent: _accent) : _EmailForm(
                  emailController: _emailController,
                  accent: _accent,
                  onSend: _sendResetLink,
                ),

                const SizedBox(height: 36),

                // Back to login
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
                          const TextSpan(text: 'Remembered it? '),
                          TextSpan(
                            text: 'Back to Sign In',
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

// ── Email form (before sending) ───────────────────────────────────────────────

class _EmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final Color accent;
  final VoidCallback onSend;

  const _EmailForm({
    required this.emailController,
    required this.accent,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(
          'EMAIL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),

        // Email input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1825),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: accent.withOpacity(0.25), width: 1),
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 14),
              prefixIcon: Icon(Icons.mail_outline_rounded,
                  color: accent.withOpacity(0.7), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Send button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded, size: 17),
            label: const Text('Send Reset Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: const Color(0xFF1A0F08),
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
        const SizedBox(height: 20),

        // Info hint
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1825),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline_rounded,
                    color: accent, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check your inbox',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'The link expires in 15 minutes. Check your spam folder if you don\'t see it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Success state (after sending) ─────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  final Color accent;
  const _SuccessState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1825),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: Colors.greenAccent, size: 26),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email sent!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve sent a password reset link to your email. It expires in 15 minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // TODO: resend logic with cooldown timer
            },
            child: Text(
              'Resend email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ),
        ],
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
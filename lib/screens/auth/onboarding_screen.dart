import 'package:app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      emoji: '🍲',
      bgEmojis: ['🐾', '🥣', '⏱', '🐟'],
      title: 'Schedule\nfeedings,\neffortlessly.',
      subtitle: 'Set custom meal times and portions — Whisker handles the rest while you relax.',
      accent: Color(0xFFE8A87C),
    ),
    _OnboardingData(
      emoji: '📷',
      bgEmojis: ['👁', '🐱', '📡', '🔴'],
      title: 'Watch your\ncat, live\nanytime.',
      subtitle: 'Built-in camera lets you check on your furball from anywhere, anytime.',
      accent: Color(0xFF7CB9E8),
    ),
    _OnboardingData(
      emoji: '🌡️',
      bgEmojis: ['💧', '🌿', '❤️', '📊'],
      title: 'Track health\nand the\nenvironment.',
      subtitle: 'Monitor temperature, humidity and activity so your cat always feels at home.',
      accent: Color(0xFFB07CE8),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _contentController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFF141018),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: _BlobPainter(_bgController.value, page.accent),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              // ── Page content ────────────────────────────────────────────
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _PageContent(
                    data: _pages[index],
                    fadeIn: _fadeIn,
                    slideUp: _slideUp,
                  );
                },
              ),

             
              // ── Bottom bar ───────────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _fadeIn,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Continue with Email
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())) ;                               },
                                icon: const Icon(Icons.mail_outline_rounded,
                                    size: 18),
                                label: const Text('Continue with Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: page.accent,
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

                            const SizedBox(height: 12),

                            // Social row
                            Row(
                              children: [
                                Expanded(
                                  child: _SocialButton(
                                    label: 'Google',
                                    icon: Icons.g_mobiledata_rounded,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SocialButton(
                                    label: 'Apple',
                                    icon: Icons.apple_rounded,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Terms
                            Text(
                              'By continuing you agree to Whisker\'s Terms of Service & Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.35),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Dot indicators ───────────────────────────────────────────
              Positioned(
                bottom: 220,
                left: 28,
                child: Row(
                  children: List.generate(_pages.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? page.accent
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page content widget ───────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> fadeIn;
  final Animation<double> slideUp;

  const _PageContent({
    required this.data,
    required this.fadeIn,
    required this.slideUp,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeIn,
      builder: (context, _) {
        return Opacity(
          opacity: fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, slideUp.value),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Illustration area ──────────────────────────────────
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Floating bg emoji blobs
                        ..._buildFloatingEmojis(data),

                        // Center hero emoji
                        Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: data.accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: data.accent.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                data.emoji,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Text content ───────────────────────────────────────
                  Text(
                    'Whisker 🐾',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: data.accent,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.55),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 240),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingEmojis(_OnboardingData data) {
    final positions = [
      const Offset(0.12, 0.15),
      const Offset(0.75, 0.10),
      const Offset(0.08, 0.65),
      const Offset(0.72, 0.60),
    ];

    return List.generate(data.bgEmojis.length, (i) {
      final pos = positions[i];
      return Positioned(
        left: pos.dx * 320,
        top: pos.dy * 320,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1825).withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: data.accent.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Text(
            data.bgEmojis[i],
            style: const TextStyle(fontSize: 22),
          ),
        ),
      );
    });
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1825),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _OnboardingData {
  final String emoji;
  final List<String> bgEmojis;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardingData({
    required this.emoji,
    required this.bgEmojis,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
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
        ry: 0.40,
      ),
      _Blob(
        color: accent.withOpacity(0.08),
        cx: 0.75 + 0.07 * math.cos(2 * math.pi * t + 1.2),
        cy: 0.55 + 0.10 * math.sin(2 * math.pi * t + 2.0),
        rx: 0.45,
        ry: 0.38,
      ),
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
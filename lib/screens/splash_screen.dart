import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeIn = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideUp = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _contentController.dispose();
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
            painter: _BlobPainter(_bgController.value),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              // ── Floating decorative elements ─────────────────────────────
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final f = _floatController.value;
                  return Stack(
                    children: [
                      // Bowl card — top left
                      Positioned(
                        top: 48 + 6 * math.sin(f * math.pi),
                        left: 28,
                        child: _FloatingCard(
                          icon: '🍲',
                          label: 'Feeding now',
                          sublabel: 'Active',
                          accent: const Color(0xFFE8A87C),
                        ),
                      ),
                      // Cat card — top right
                      Positioned(
                        top: 90 + 8 * math.cos(f * math.pi + 1.0),
                        right: 20,
                        child: _FloatingCard(
                          icon: '🐱',
                          label: 'Luna is eating',
                          sublabel: 'Live cam',
                          accent: const Color(0xFF7CB9E8),
                        ),
                      ),
                      // Temp badge — mid right
                      Positioned(
                        top: 200 + 5 * math.sin(f * math.pi + 2.5),
                        right: 16,
                        child: _SmallBadge(icon: '🌡️', value: '22°C'),
                      ),
                      // Schedule badge — mid left
                      Positioned(
                        top: 220 + 7 * math.cos(f * math.pi + 0.8),
                        left: 20,
                        child: _SmallBadge(icon: '⏱', value: '8:00 AM'),
                      ),
                    ],
                  );
                },
              ),

              // ── Diamond arrow — bleeds off right edge ─────────────────
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, _) {
                 return Positioned(
                    right: -38,
                    bottom: 148,
                    child: Transform.scale(
                      scale: _buttonScale.value,
                      child: Transform.rotate(
                        angle: math.pi / 4,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A87C),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Transform.rotate(
                            angle: -math.pi / 4,
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF1A0F08),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Bottom content ────────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category label
                              Text(
                                'Smart Pet Care  🐾',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE8A87C),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Headline + arrow side by side
                              const Text(
                                'Feed, watch\nand care for\nyour cat.',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -1.0,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Get Started button
                              Transform.scale(
                                scale: _buttonScale.value,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 180,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFE8A87C),
                                      foregroundColor:
                                          const Color(0xFF1A0F08),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating info card ────────────────────────────────────────────────────────

class _FloatingCard extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;
  final Color accent;

  const _FloatingCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1825).withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small badge ───────────────────────────────────────────────────────────────

class _SmallBadge extends StatelessWidget {
  final String icon;
  final String value;

  const _SmallBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1825).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF141018));

    final blobs = [
      _Blob(
        color: const Color(0xFFE8A87C).withOpacity(0.18),
        cx: 0.15 + 0.08 * math.sin(2 * math.pi * t),
        cy: 0.20 + 0.08 * math.cos(2 * math.pi * t + 0.5),
        rx: 0.55,
        ry: 0.40,
      ),
      _Blob(
        color: const Color(0xFF7CB9E8).withOpacity(0.12),
        cx: 0.80 + 0.07 * math.cos(2 * math.pi * t + 1.2),
        cy: 0.35 + 0.10 * math.sin(2 * math.pi * t + 2.0),
        rx: 0.45,
        ry: 0.38,
      ),
      _Blob(
        color: const Color(0xFFB07CE8).withOpacity(0.10),
        cx: 0.50 + 0.10 * math.sin(2 * math.pi * t + 3.0),
        cy: 0.65 + 0.06 * math.cos(2 * math.pi * t + 1.5),
        rx: 0.50,
        ry: 0.35,
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
  bool shouldRepaint(_BlobPainter old) => old.t != t;
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class OtpVerificationScreen extends StatefulWidget {
  final String phoneOrEmail; // e.g. "+216 •••• •• 47"

  const OtpVerificationScreen({
    super.key,
    required this.phoneOrEmail,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  static const int _otpLength = 6;
  static const int _timerSeconds = 120; // 2 minutes
  static const _accent = Color(0xFFE8A87C);

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late int _secondsLeft;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = _timerSeconds;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpCode.length == _otpLength;

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all filled
    if (_isComplete) _verify();
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verify() {
    // TODO: send _otpCode to your auth service
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _resend() {
    if (!_canResend) return;
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    _startTimer();
    // TODO: trigger resend API call
  }

  @override
  void dispose() {
    _bgController.dispose();
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141018),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) => CustomPaint(
          painter: _BlobPainter(_bgController.value, _accent),
          child: child,
        ),
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
                    border: Border.all(
                        color: _accent.withOpacity(0.25), width: 1),
                  ),
                  child: Icon(Icons.phone_outlined,
                      color: _accent, size: 30),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify your\nnumber.',
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
                  'We sent a 6-digit code to',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneOrEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 36),

                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_otpLength, (i) {
                    final isFocused = _focusNodes[i].hasFocus;
                    final isFilled = _controllers[i].text.isNotEmpty;
                    return SizedBox(
                      width: 46,
                      height: 60,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (e) => _onKeyEvent(e, i),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFF1E1825),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isFilled
                                    ? _accent.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: _accent, width: 1.5),
                            ),
                          ),
                          onChanged: (v) => _onChanged(v, i),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Timer
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14,
                          color: _accent.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        _canResend
                            ? 'Code expired'
                            : 'Code expires in ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      if (!_canResend)
                        Text(
                          _timerLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isComplete ? _verify : null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Verify Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      disabledBackgroundColor: _accent.withOpacity(0.3),
                      foregroundColor: const Color(0xFF1A0F08),
                      disabledForegroundColor:
                          const Color(0xFF1A0F08).withOpacity(0.4),
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

                // Resend button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _canResend ? _resend : null,
                    icon: Icon(Icons.refresh_rounded,
                        size: 17,
                        color: _canResend
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.2)),
                    label: Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _canResend
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      backgroundColor: const Color(0xFF1E1825),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Hint card
                Container(
                  padding: const EdgeInsets.all(14),
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
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(Icons.info_outline_rounded,
                            color: _accent, size: 15),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Didn\'t receive anything?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Check your spam or wait 2 minutes before requesting a new code.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.3),
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
            ),
          ),
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
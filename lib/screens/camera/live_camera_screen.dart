import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  bool _nightMode = false;
  bool _meowDetect = true;
  bool _isFullscreen = false;

  // TODO: replace with real stream data from your service
  final String _latency = '24ms';
  final String _bitrate = '1.2 MB/s';
  final String _quality = '720p';
  final double _temperature = 24.0;
  final int _humidity = 58;
  final bool _motionDetected = true;

  // Simulated live clock
  late final Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildVideoPlayer(),
              const SizedBox(height: 12),
              _buildStreamStats(),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 12),
              _buildEnvironmentBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHISKER 🐾',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Live Camera',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Quality selector
            _IconBtn(
              icon: Icons.tune_rounded,
              onTap: () {
                // TODO: show quality picker bottom sheet
              },
            ),
            const SizedBox(width: 8),
            // Fullscreen
            _IconBtn(
              icon: _isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              onTap: _toggleFullscreen,
            ),
          ],
        ),
      ],
    );
  }

  // ── Video player area ────────────────────────────────────────────────────────

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          color: const Color(0xFF0a0810),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // TODO: replace with your actual stream widget
              // e.g. flutter_vlc_player, video_player, or an MJPEG Image widget:
              // Image.network(
              //   'http://your-feeder-ip/stream',
              //   fit: BoxFit.cover,
              // )
              _buildStreamPlaceholder(),

              // Top bar — LIVE badge + quality
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LIVE badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF87171),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text('LIVE',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    // Quality pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_quality,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7))),
                    ),
                  ],
                ),
              ),

              // Bottom bar — clock + screenshot + flip
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Live clock
                    StreamBuilder<DateTime>(
                      stream: _clockStream,
                      builder: (context, snap) {
                        final time = snap.hasData
                            ? _formatTime(snap.data!)
                            : '--:--:--';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.white.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Text(time,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        // Screenshot
                        _OverlayBtn(
                          icon: Icons.camera_alt_outlined,
                          onTap: () {
                            // TODO: capture screenshot from stream
                          },
                        ),
                        const SizedBox(width: 6),
                        // Skip / flip
                        _OverlayBtn(
                          icon: Icons.flip_camera_ios_outlined,
                          onTap: () {
                            // TODO: flip camera if hardware supports it
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamPlaceholder() {
    return Container(
      color: const Color(0xFF0f0c18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined,
              size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          Text(
            _isOnline
                ? 'Connecting to stream...'
                : 'Camera offline',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  // ── Stream stats row ─────────────────────────────────────────────────────────

  Widget _buildStreamStats() {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            label: 'Status',
            value: _isOnline ? 'Online' : 'Offline',
            valueColor:
                _isOnline ? Colors.greenAccent.shade400 : Colors.redAccent,
            dotColor:
                _isOnline ? Colors.greenAccent.shade400 : Colors.redAccent,
            hasBorder: true,
            borderColor: _isOnline
                ? Colors.greenAccent.withOpacity(0.2)
                : Colors.redAccent.withOpacity(0.2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(label: 'Latency', value: _latency),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(label: 'Bitrate', value: _bitrate),
        ),
      ],
    );
  }

  // ── Quick actions grid ───────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Feed Now — primary
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: show FeedNowConfirmScreen or bottom sheet
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_arrow_rounded,
                            size: 16, color: Color(0xFF1A0F08)),
                        SizedBox(width: 6),
                        Text('Feed Now',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A0F08))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Talk
              Expanded(
                child: _ActionBtn(
                  icon: Icons.mic_outlined,
                  label: 'Talk',
                  onTap: () {
                    // TODO: open two-way audio
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Night mode toggle
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _nightMode = !_nightMode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      color: _nightMode
                          ? AppColors.accent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _nightMode
                            ? AppColors.accent.withOpacity(0.3)
                            : Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.nights_stay_outlined,
                          size: 15,
                          color: _nightMode
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Night mode',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _nightMode
                                ? AppColors.accent
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Meow detect toggle
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _meowDetect = !_meowDetect),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      color: _meowDetect
                          ? AppColors.accent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _meowDetect
                            ? AppColors.accent.withOpacity(0.3)
                            : Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hearing_outlined,
                          size: 15,
                          color: _meowDetect
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Meow detect',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _meowDetect
                                ? AppColors.accent
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Environment bar ──────────────────────────────────────────────────────────

  Widget _buildEnvironmentBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENVIRONMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EnvTile(
                  icon: Icons.thermostat_outlined,
                  iconColor: const Color(0xFF60a5fa),
                  value: '${_temperature.toStringAsFixed(0)}°C',
                  label: 'Temp',
                ),
              ),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.06)),
              Expanded(
                child: _EnvTile(
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF6ee7b7),
                  value: '$_humidity%',
                  label: 'Humidity',
                ),
              ),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.06)),
              Expanded(
                child: _EnvTile(
                  icon: Icons.bolt_outlined,
                  iconColor: AppColors.accent,
                  value: _motionDetected ? 'Active' : 'None',
                  label: 'Motion',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border:
              Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}

class _OverlayBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OverlayBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? dotColor;
  final bool hasBorder;
  final Color? borderColor;

  const _StatPill({
    required this.label,
    required this.value,
    this.valueColor,
    this.dotColor,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasBorder && borderColor != null
              ? borderColor!
              : Colors.white.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (dotColor != null) ...[
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: dotColor, shape: BoxShape.circle)),
            const SizedBox(height: 5),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

class _EnvTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _EnvTile(
      {required this.icon,
      required this.iconColor,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withOpacity(0.35))),
      ],
    );
  }
}
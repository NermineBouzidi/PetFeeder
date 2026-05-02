import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../auth/login_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../settings/change_password_screen.dart';
import './notification_settings_screen.dart';
import './device_settings_screen.dart';
import './device_setup_screen.dart';
import '../settings/about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // TODO: replace with real user data from AuthProvider
  static const _userName = 'Karim Ben Ali';
  static const _userEmail = 'karim@example.com';
  static const _userInitial = 'K';
  static const _scheduleCount = 12;
  static const _mealsFed = 84;
  static const _petCount = 1;
  static const _wifiName = 'Home_Network_5G';
  static const _appVersion = 'v1.0.0 (build 42)';
  static const _feederConnected = true;

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
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildUserCard(context),
              const SizedBox(height: 14),
              _buildStatsRow(),
              const SizedBox(height: 14),
              _buildSection(
                label: 'ACCOUNT',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit profile',
                    onTap: () => Navigator.push(context,
                        _route(const EditProfileScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change password',
                    onTap: () => Navigator.push(context,
                        _route(const ChangePasswordScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.push(context,
                        _route(const NotificationSettingsScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildSection(
                label: 'DEVICE',
                iconColor: const Color(0xFF7CB9E8),
                items: [
                  _SettingsItem(
                    icon: Icons.settings_outlined,
                    label: 'Feeder settings',
                    iconColor: const Color(0xFF7CB9E8),
                    onTap: () => Navigator.push(context,
                        _route(const DeviceSettingsScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.refresh_rounded,
                    label: 'Reconnect feeder',
                    iconColor: const Color(0xFF7CB9E8),
                    onTap: () => Navigator.push(context,
                        _route(const DeviceSetupScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.wifi_rounded,
                    label: 'WiFi network',
                    subtitle: _wifiName,
                    iconColor: const Color(0xFF7CB9E8),
                    onTap: () {
                      // TODO: show WiFi change dialog
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildSection(
                label: 'APP',
                items: [
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About Whisker',
                    iconColor: Colors.white.withOpacity(0.4),
                    onTap: () => Navigator.push(
                        context, _route(const AboutScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: 'App version',
                    subtitle: _appVersion,
                    iconColor: Colors.white.withOpacity(0.4),
                    showChevron: false,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
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
            const Text('Profile',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
        // Settings cog
        GestureDetector(
          onTap: () {
            // TODO: navigate to full SettingsScreen
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Icon(Icons.settings_outlined,
                size: 16, color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  // ── User card ────────────────────────────────────────────────────────────────

  Widget _buildUserCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: AppColors.accent.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                _userInitial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(_userName,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(_userEmail,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 8),
                // Feeder status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _feederConnected
                        ? Colors.greenAccent.withOpacity(0.1)
                        : Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: _feederConnected
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.redAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _feederConnected
                              ? Colors.greenAccent.shade400
                              : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _feederConnected
                            ? 'Feeder connected'
                            : 'Feeder offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _feederConnected
                              ? Colors.greenAccent.shade400
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () => Navigator.push(
                context, _route(const EditProfileScreen())),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.edit_outlined,
                  color: AppColors.accent, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(label: 'Schedules', value: '$_scheduleCount'),
        const SizedBox(width: 8),
        _StatCard(label: 'Meals fed', value: '$_mealsFed'),
        const SizedBox(width: 8),
        _StatCard(
            label: 'Pet',
            value: '$_petCount',
            valueColor: AppColors.accent),
      ],
    );
  }

  // ── Settings section ─────────────────────────────────────────────────────────

  Widget _buildSection({
    required String label,
    required List<_SettingsItem> items,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.35),
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...items.map((item) => _SettingsTile(item: item)),
        ],
      ),
    );
  }

  // ── Sign out ─────────────────────────────────────────────────────────────────

  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignOutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.redAccent.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFF87171), size: 15),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF87171),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1825),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
          'Your schedules and pet data will remain saved.',
          style: TextStyle(
              color: Colors.white.withOpacity(0.5), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: clear auth token from storage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Sign out',
                style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  PageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}

// ── Settings item model ───────────────────────────────────────────────────────

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.showChevron = true,
  });
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;
  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor = item.iconColor ?? AppColors.accent;
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85))),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(item.subtitle!,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.35))),
                  ],
                ],
              ),
            ),
            if (item.showChevron)
              Icon(Icons.chevron_right_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatCard(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35))),
          ],
        ),
      ),
    );
  }
}
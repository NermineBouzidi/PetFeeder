import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  bool get _passwordsMatch =>
      _newCtrl.text.isNotEmpty && _newCtrl.text == _confirmCtrl.text;

  Future<void> _update() async {
    if (!_passwordsMatch) return;

    if (_newCtrl.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      // Re-authenticate with current password first
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Then update to new password
      await user.updatePassword(_newCtrl.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Password updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showError('Current password is incorrect');
      } else {
        _showError(e.message ?? 'Something went wrong');
      }
    } catch (e) {
      _showError('Something went wrong');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackHeader(title: 'Change Password'),
              const SizedBox(height: 28),

              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your current password to confirm it\'s you, then set a new one.',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4), height: 1.6),
              ),
              const SizedBox(height: 28),

              _AuthField(
                label: 'CURRENT PASSWORD',
                controller: _currentCtrl,
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureCurrent,
                suffixIcon: _obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                onSuffixTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 14),
              _AuthField(
                label: 'NEW PASSWORD',
                controller: _newCtrl,
                icon: Icons.shield_outlined,
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                suffixIcon: _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                onSuffixTap: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 14),
              _AuthField(
                label: 'CONFIRM NEW PASSWORD',
                controller: _confirmCtrl,
                icon: Icons.shield_outlined,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                suffixIcon: _passwordsMatch
                    ? Icons.check_circle_rounded
                    : (_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                suffixColor: _passwordsMatch ? Colors.greenAccent.shade400 : null,
                onSuffixTap: _passwordsMatch
                    ? null
                    : () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 10),

              if (_confirmCtrl.text.isNotEmpty)
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _passwordsMatch ? Colors.greenAccent.shade400 : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _passwordsMatch ? 'Passwords match' : 'Passwords do not match',
                    style: TextStyle(
                      fontSize: 12,
                      color: _passwordsMatch ? Colors.greenAccent.shade400 : Colors.redAccent,
                    ),
                  ),
                ]),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: (_passwordsMatch && !_isLoading) ? _update : null,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 17, height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 17),
                  label: Text(_isLoading ? 'Updating...' : 'Update password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.3),
                    foregroundColor: const Color(0xFF1A0F08),
                    disabledForegroundColor: const Color(0xFF1A0F08).withOpacity(0.4),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Back header ───────────────────────────────────────────────────────────────

class _BackHeader extends StatelessWidget {
  final String title;
  const _BackHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: Colors.white.withOpacity(0.7), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;
  final Color? suffixColor;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const _AuthField({
    required this.label,
    required this.controller,
    this.icon = Icons.edit_outlined,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixColor,
    this.onSuffixTap,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1825),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.accent.withOpacity(0.6), size: 18),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(suffixIcon,
                          color: suffixColor ?? Colors.white.withOpacity(0.3), size: 18),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
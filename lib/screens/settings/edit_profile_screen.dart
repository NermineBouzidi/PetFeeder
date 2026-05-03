import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final user = context.read<UserProvider>().user;
    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text  = user?.lastName ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<UserProvider>().updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final initial = user != null ? user.firstName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackHeader(title: 'Edit Profile'),
              const SizedBox(height: 28),

              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
                      ),
                      child: Center(
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _AuthField(
                label: 'FIRST NAME',
                controller: _firstNameController,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _AuthField(
                label: 'LAST NAME',
                controller: _lastNameController,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 17, height: 17,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 17),
                  label: Text(_isLoading ? 'Saving...' : 'Save changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF1A0F08),
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
  final TextInputType keyboardType;

  const _AuthField({
    required this.label,
    required this.controller,
    this.icon = Icons.edit_outlined,
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
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.accent.withOpacity(0.6), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
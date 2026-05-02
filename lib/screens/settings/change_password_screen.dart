import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('Change Password'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field('Current Password'),
            const SizedBox(height: 12),
            _field('New Password'),
            const SizedBox(height: 12),
            _field('Confirm Password'),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }

  Widget _field(String label) {
    return TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _button() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(child: Text('Update Password')),
      );

  AppBar _appBar(String title) =>
      AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(title));
}
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('Edit Profile'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _inputField('Full Name'),
            const SizedBox(height: 12),
            _inputField('Email'),
            const SizedBox(height: 20),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text('Save',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  AppBar _appBar(String title) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      );
}
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class DeviceSetupScreen extends StatelessWidget {
  const DeviceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('Setup Device'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi, size: 60, color: AppColors.accent),
            const SizedBox(height: 20),
            const Text('Searching for feeder...',
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }

  Widget _button() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('Retry'),
      );

  AppBar _appBar(String t)=>AppBar(backgroundColor: Colors.transparent,elevation:0,title:Text(t));
}
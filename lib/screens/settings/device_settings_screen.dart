import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class DeviceSettingsScreen extends StatelessWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('Feeder Settings'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile('Portion Size', 'Adjust feeding amount'),
            _tile('Feeding Mode', 'Auto / Manual'),
            _tile('Sound Alerts', 'Enabled'),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4))),
            ],
          )),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))
        ],
      ),
    );
  }

  AppBar _appBar(String t)=>AppBar(backgroundColor: Colors.transparent,elevation:0,title:Text(t));
}
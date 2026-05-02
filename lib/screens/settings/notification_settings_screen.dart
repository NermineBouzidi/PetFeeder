import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('Notifications'),
      body: Column(
        children: [
          _switchTile('Feeding Alerts'),
          _switchTile('Device Offline'),
        ],
      ),
    );
  }

  Widget _switchTile(String label) {
    return SwitchListTile(
      value: true,
      onChanged: (_) {},
      title: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  AppBar _appBar(String t)=>AppBar(backgroundColor: Colors.transparent,elevation:0,title:Text(t));
}
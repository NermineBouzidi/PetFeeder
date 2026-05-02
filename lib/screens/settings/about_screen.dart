import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('About'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Whisker is a smart pet feeder app that helps you manage feeding schedules and monitor your pet remotely.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  AppBar _appBar(String t)=>AppBar(backgroundColor: Colors.transparent,elevation:0,title:Text(t));
}
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar('History'),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (_, i) => _item(),
      ),
    );
  }

  Widget _item() => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('Meal dispensed at 08:30',
            style: TextStyle(color: Colors.white)),
      );

  AppBar _appBar(String t)=>AppBar(backgroundColor: Colors.transparent,elevation:0,title:Text(t));
}
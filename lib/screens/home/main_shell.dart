// main_shell.dart
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../pet/pet_screen.dart';        // ← changed
import '../schedule/schedule_screen.dart';
import '../settings/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    PetScreen(),           // ← changed
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141018),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        badgeIndices: const [2],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
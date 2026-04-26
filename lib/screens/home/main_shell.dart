import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../camera/live_camera_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Keep all tabs alive when switching — no rebuilds
  final List<Widget> _tabs = const [
    HomeScreen(),
    LiveCameraScreen(),
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
        badgeIndices: const [2], // Schedule has a badge — remove when no alerts
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
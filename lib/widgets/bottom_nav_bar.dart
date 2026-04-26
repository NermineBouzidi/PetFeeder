import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<int> badgeIndices; // which tabs show a badge dot

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeIndices = const [],
  });

  static const _items = [
    _NavItem(label: 'Home',     icon: Icons.home_outlined,           activeIcon: Icons.home_rounded),
    _NavItem(label: 'Camera',   icon: Icons.videocam_outlined,       activeIcon: Icons.videocam_rounded),
    _NavItem(label: 'Schedule', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded),
    _NavItem(label: 'Profile',  icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1320),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.07),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              return Expanded(
                child: _NavTile(
                  item: _items[i],
                  isActive: currentIndex == i,
                  hasBadge: badgeIndices.contains(i),
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Single nav tile ───────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon + optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 20,
                    color: isActive
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.3),
                  ),
                ),

                // Badge dot
                if (hasBadge)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1A1320),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.3),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
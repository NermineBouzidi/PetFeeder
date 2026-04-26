import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../schedule/add_schedule_screen.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum ScheduleFilter { all, active, paused }

class ScheduleModel {
  final String id;
  final String label;
  final TimeOfDay time;
  final int grams;
  final List<int> days; // 1=Mon ... 7=Sun
  bool isActive;

  ScheduleModel({
    required this.id,
    required this.label,
    required this.time,
    required this.grams,
    required this.days,
    this.isActive = true,
  });

  String get formattedTime {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String get daysLabel {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (days.length == 7) return 'Everyday';
    return days.map((d) => names[d - 1]).join(', ');
  }

  String get nextOccurrence {
    if (!isActive) return 'Paused';
    final now = DateTime.now();
    final todayIndex = now.weekday; // 1=Mon
    // Find next day
    for (int offset = 0; offset < 8; offset++) {
      final checkDay = ((todayIndex - 1 + offset) % 7) + 1;
      if (days.contains(checkDay)) {
        if (offset == 0) {
          final nowMinutes = now.hour * 60 + now.minute;
          final schedMinutes = time.hour * 60 + time.minute;
          if (schedMinutes > nowMinutes) return 'Today';
        } else if (offset == 1) {
          return 'Tomorrow';
        } else {
          const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return names[checkDay - 1];
        }
      }
    }
    return 'N/A';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleFilter _filter = ScheduleFilter.all;

  // TODO: replace with real data from ScheduleProvider
  final List<ScheduleModel> _schedules = [
    ScheduleModel(
      id: '1',
      label: 'Morning meal',
      time: const TimeOfDay(hour: 7, minute: 0),
      grams: 50,
      days: [1, 2, 3, 4, 5, 6, 7],
      isActive: true,
    ),
    ScheduleModel(
      id: '2',
      label: 'Midday meal',
      time: const TimeOfDay(hour: 12, minute: 30),
      grams: 40,
      days: [1, 3, 5],
      isActive: true,
    ),
    ScheduleModel(
      id: '3',
      label: 'Evening meal',
      time: const TimeOfDay(hour: 18, minute: 0),
      grams: 50,
      days: [1, 2, 3, 4, 5, 6, 7],
      isActive: false,
    ),
    ScheduleModel(
      id: '4',
      label: 'Night snack',
      time: const TimeOfDay(hour: 21, minute: 0),
      grams: 20,
      days: [6, 7],
      isActive: true,
    ),
  ];

  List<ScheduleModel> get _filtered {
    switch (_filter) {
      case ScheduleFilter.active:
        return _schedules.where((s) => s.isActive).toList();
      case ScheduleFilter.paused:
        return _schedules.where((s) => !s.isActive).toList();
      case ScheduleFilter.all:
        return _schedules;
    }
  }

  int get _totalGramsToday {
    final today = DateTime.now().weekday;
    return _schedules
        .where((s) => s.isActive && s.days.contains(today))
        .fold(0, (sum, s) => sum + s.grams);
  }

  void _toggleSchedule(ScheduleModel s) {
    setState(() => s.isActive = !s.isActive);
    // TODO: push toggle to MQTT / backend
  }

  void _deleteSchedule(ScheduleModel s) {
    setState(() => _schedules.removeWhere((e) => e.id == s.id));
    // TODO: delete from backend
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddScheduleScreen()),
    );
    if (result != null && result is ScheduleModel) {
      setState(() => _schedules.add(result));
    }
  }

  void _navigateToEdit(ScheduleModel s) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddScheduleScreen(existing: s)),
    );
    if (result != null && result is ScheduleModel) {
      setState(() {
        final idx = _schedules.indexWhere((e) => e.id == result.id);
        if (idx != -1) _schedules[idx] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSummaryBar(),
                    const SizedBox(height: 16),
                    _buildFilterRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _filtered.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ScheduleCard(
                            schedule: _filtered[i],
                            onToggle: () => _toggleSchedule(_filtered[i]),
                            onEdit: () => _navigateToEdit(_filtered[i]),
                            onDelete: () => _deleteSchedule(_filtered[i]),
                          ),
                        ),
                        childCount: _filtered.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHISKER 🐾',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            const Text('Schedule',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
        // Add button
        GestureDetector(
          onTap: _navigateToAdd,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_rounded,
                color: Color(0xFF1A0F08), size: 20),
          ),
        ),
      ],
    );
  }

  // ── Summary bar ──────────────────────────────────────────────────────────────

  Widget _buildSummaryBar() {
    final activeCount = _schedules.where((s) => s.isActive).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Active',
            value: '$activeCount',
            color: Colors.greenAccent.shade400,
          ),
          _divider(),
          _SummaryChip(
            label: 'Total',
            value: '${_schedules.length}',
            color: Colors.white,
          ),
          _divider(),
          _SummaryChip(
            label: 'Today',
            value: '${_totalGramsToday}g',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withOpacity(0.07));

  // ── Filter row ───────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Row(
      children: ScheduleFilter.values.map((f) {
        final label =
            f.name[0].toUpperCase() + f.name.substring(1);
        final isActive = _filter == f;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: f != ScheduleFilter.paused ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? AppColors.accent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(
            'No schedules yet',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first feeding schedule',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withOpacity(0.25)),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _navigateToAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Add Schedule',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A0F08))),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule card ─────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final next = schedule.nextOccurrence;
    final isPaused = !schedule.isActive;

    return Opacity(
      opacity: isPaused ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: schedule.isActive
                  ? AppColors.accent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.07),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: schedule.isActive
                          ? AppColors.accent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: schedule.isActive
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Label + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: schedule.isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5))),
                        const SizedBox(height: 2),
                        Text(
                            '${schedule.formattedTime} · ${schedule.grams}g',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4))),
                      ],
                    ),
                  ),

                  // Toggle switch
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 22,
                      decoration: BoxDecoration(
                        color: schedule.isActive
                            ? AppColors.accent
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: schedule.isActive
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // More menu
                  GestureDetector(
                    onTap: () => _showOptions(context),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.more_vert_rounded,
                          size: 18,
                          color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                ],
              ),

              // Days + next badge
              const SizedBox(height: 12),
              Divider(
                  height: 1, color: Colors.white.withOpacity(0.06)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ..._buildDayChips(),
                        _NextBadge(next: next, isActive: schedule.isActive),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDayChips() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (schedule.days.length == 7) {
      return [
        _DayChip(label: 'Everyday', isActive: schedule.isActive),
      ];
    }
    return schedule.days
        .map((d) => _DayChip(
            label: names[d - 1], isActive: schedule.isActive))
        .toList();
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1825),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: Icon(Icons.edit_outlined,
                  color: Colors.white.withOpacity(0.7)),
              title: Text('Edit',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85))),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                schedule.isActive
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                color: Colors.white.withOpacity(0.7),
              ),
              title: Text(
                schedule.isActive ? 'Pause' : 'Resume',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85)),
              ),
              onTap: () {
                Navigator.pop(context);
                onToggle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFF87171)),
              title: const Text('Delete',
                  style: TextStyle(color: Color(0xFFF87171))),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _DayChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _DayChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent.withOpacity(0.12)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive
              ? AppColors.accent
              : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _NextBadge extends StatelessWidget {
  final String next;
  final bool isActive;
  const _NextBadge({required this.next, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final isPaused = !isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaused
            ? Colors.redAccent.withOpacity(0.1)
            : Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPaused
              ? Colors.redAccent.withOpacity(0.2)
              : Colors.greenAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        isPaused ? 'Paused' : 'Next: $next',
        style: TextStyle(
          fontSize: 11,
          color: isPaused
              ? const Color(0xFFF87171)
              : Colors.greenAccent.shade400,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }
}
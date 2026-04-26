import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../schedule/schedule_screen.dart'; // for ScheduleModel

class AddScheduleScreen extends StatefulWidget {
  final ScheduleModel? existing;

  const AddScheduleScreen({super.key, this.existing});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _labelController = TextEditingController();
  final _gramsController = TextEditingController();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  List<int> _selectedDays = [];
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final s = widget.existing!;
      _labelController.text = s.label;
      _gramsController.text = s.grams.toString();
      _selectedTime = s.time;
      _selectedDays = List.from(s.days);
      _isActive = s.isActive;
    } else {
      _selectedDays = [1, 2, 3, 4, 5, 6, 7];
    }
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _save() {
    if (_labelController.text.isEmpty ||
        _gramsController.text.isEmpty ||
        _selectedDays.isEmpty) return;

    final newSchedule = ScheduleModel(
      id: widget.existing?.id ?? DateTime.now().toString(),
      label: _labelController.text,
      time: _selectedTime,
      grams: int.parse(_gramsController.text),
      days: _selectedDays,
      isActive: _isActive,
    );

    Navigator.pop(context, newSchedule);
  }

  String get _formattedTime {
    final h = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    final period =
        _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInputCard(),
                      const SizedBox(height: 14),
                      _buildTimeCard(),
                      const SizedBox(height: 14),
                      _buildDaysCard(),
                      const SizedBox(height: 14),
                      _buildToggleCard(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.existing != null ? 'Edit Schedule' : 'Add Schedule',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ],
    );
  }

  // ── Input Card ─────────────────────────────────────

  Widget _buildInputCard() {
    return _card(
      child: Column(
        children: [
          _inputField(
            controller: _labelController,
            hint: 'Meal label (e.g. Morning meal)',
            icon: Icons.fastfood_rounded,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _gramsController,
            hint: 'Grams (e.g. 50)',
            icon: Icons.scale_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ── Time Card ──────────────────────────────────────

  Widget _buildTimeCard() {
    return _card(
      child: Row(
        children: [
          Icon(Icons.access_time_rounded,
              color: AppColors.accent),
          const SizedBox(width: 10),
          const Text('Time',
              style: TextStyle(color: Colors.white)),
          const Spacer(),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_formattedTime,
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  // ── Days Card ──────────────────────────────────────

  Widget _buildDaysCard() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Days',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _selectedDays.contains(day);

              return GestureDetector(
                onTap: () => _toggleDay(day),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    names[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Toggle Card ────────────────────────────────────

  Widget _buildToggleCard() {
    return _card(
      child: Row(
        children: [
          const Text('Active',
              style: TextStyle(color: Colors.white)),
          const Spacer(),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: AppColors.accent,
          )
        ],
      ),
    );
  }

  // ── Save Button ────────────────────────────────────

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Save Schedule',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0F08))),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: child,
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.accent),
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
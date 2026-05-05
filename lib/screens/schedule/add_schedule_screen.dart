import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/schedule_service.dart'; // ← adjust path if needed

// ─────────────────────────────────────────────────────────────────────────────
// AddScheduleScreen
//   • Pass existing: ScheduleModel  → Edit mode
//   • Pass nothing                  → Create mode
//   • Returns ScheduleModel via Navigator.pop when saved (already persisted)
// ─────────────────────────────────────────────────────────────────────────────

class AddScheduleScreen extends StatefulWidget {
  final ScheduleModel? existing;

  const AddScheduleScreen({super.key, this.existing});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _service         = ScheduleService();
  final _labelController = TextEditingController();
  final _gramsController = TextEditingController();

  TimeOfDay   _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  List<int>   _selectedDays = [];   // 0=Sun … 6=Sat  (JS weekday)
  bool        _isActive     = true;
  bool        _saving       = false;
  String?     _errorMessage;

  bool get _isEdit => widget.existing != null;

  // ── Day labels (JS weekday order: 0=Sun…6=Sat) ────────────────────────────
  static const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final s = widget.existing!;
      _labelController.text = s.label;
      _gramsController.text = s.grams.toString();
      _selectedTime = s.time;
      _selectedDays = List<int>.from(s.days);
      _isActive     = s.isActive;
    } else {
      // Default: every day
      _selectedDays = [0, 1, 2, 3, 4, 5, 6];
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  // ── Time picker ───────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: AppColors.accent),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: const Color(0xFF1E1825),
            hourMinuteTextColor: Colors.white,
            dialHandColor: AppColors.accent,
            dialBackgroundColor: const Color(0xFF2A2035),
            entryModeIconColor: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _toggleDay(int day) {
    setState(() {
      _selectedDays.contains(day)
          ? _selectedDays.remove(day)
          : _selectedDays.add(day);
    });
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validate() {
    if (_labelController.text.trim().isEmpty) return 'Please enter a meal label';
    final grams = int.tryParse(_gramsController.text.trim());
    if (grams == null || grams <= 0) return 'Please enter a valid gram amount';
    if (_selectedDays.isEmpty) return 'Please select at least one day';
    return null;
  }

  // ── Save (create or update) ───────────────────────────────────────────────
  Future<void> _save() async {
    final err = _validate();
    if (err != null) {
      setState(() => _errorMessage = err);
      return;
    }

    setState(() { _saving = true; _errorMessage = null; });

    try {
      final draft = ScheduleModel(
        id      : widget.existing?.id,
        label   : _labelController.text.trim(),
        time    : _selectedTime,
        grams   : int.parse(_gramsController.text.trim()),
        days    : List<int>.from(_selectedDays),
        isActive: _isActive,
      );

      final saved = _isEdit
          ? await _service.update(draft)
          : await _service.create(draft);

      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      setState(() {
        _saving       = false;
        _errorMessage = 'Server error: ${e.toString()}';
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildInputCard(),
                      const SizedBox(height: 12),
                      _buildTimeCard(),
                      const SizedBox(height: 12),
                      _buildDaysCard(),
                      const SizedBox(height: 12),
                      _buildActiveToggleCard(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorBanner(),
                      ],
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

  // ── Header ────────────────────────────────────────────────────────────────
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
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHISKER 🐾',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.accent.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              _isEdit ? 'Edit Schedule' : 'New Schedule',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Input card (label + grams) ────────────────────────────────────────────
  Widget _buildInputCard() {
    return _card(
      child: Column(
        children: [
          _inputField(
            controller: _labelController,
            hint      : 'Meal label  (e.g. Morning meal)',
            icon      : Icons.fastfood_rounded,
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 10),
          _inputField(
            controller  : _gramsController,
            hint        : 'Portion (grams)',
            icon        : Icons.scale_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ── Time card ─────────────────────────────────────────────────────────────
  Widget _buildTimeCard() {
    final h      = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final m      = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final label  = '$h:$m $period';

    return _card(
      child: Row(
        children: [
          Container(
            width : 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.access_time_rounded,
                color: AppColors.accent, size: 16),
          ),
          const SizedBox(width: 12),
          const Text('Feeding time',
              style: TextStyle(
                  fontSize: 14, color: Colors.white,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color        : AppColors.accent.withOpacity(0.15),
                borderRadius : BorderRadius.circular(10),
                border       : Border.all(
                    color: AppColors.accent.withOpacity(0.3), width: 1),
              ),
              child: Text(label,
                  style: TextStyle(
                    color     : AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize  : 15,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Days card ─────────────────────────────────────────────────────────────
  Widget _buildDaysCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width : 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_outlined,
                    color: Colors.purpleAccent, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('Repeat on',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedDays.length == 7) {
                      _selectedDays.clear();
                    } else {
                      _selectedDays = [0, 1, 2, 3, 4, 5, 6];
                    }
                  });
                },
                child: Text(
                  _selectedDays.length == 7 ? 'Clear all' : 'Select all',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 7 day buttons in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final selected = _selectedDays.contains(i);
              return GestureDetector(
                onTap: () => _toggleDay(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width : 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayNames[i][0], // S M T W T F S
                      style: TextStyle(
                        fontSize  : 12,
                        fontWeight: FontWeight.w700,
                        color     : selected
                            ? const Color(0xFF1A0F08)
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Show full day names below the buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return SizedBox(
                width: 38,
                child: Center(
                  child: Text(
                    _dayNames[i],
                    style: TextStyle(
                      fontSize: 9,
                      color: _selectedDays.contains(i)
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.2),
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

  // ── Active toggle card ────────────────────────────────────────────────────
  Widget _buildActiveToggleCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width : 32,
            height: 32,
            decoration: BoxDecoration(
              color: (_isActive
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.15))
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isActive
                  ? Icons.play_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              color: _isActive
                  ? Colors.greenAccent.shade400
                  : Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enable schedule',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              Text(
                _isActive ? 'Will run automatically' : 'Paused — won\'t fire',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.35)),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isActive = !_isActive),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width : 46,
              height: 26,
              decoration: BoxDecoration(
                color: _isActive
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration : const Duration(milliseconds: 200),
                alignment: _isActive
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width : 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error banner ──────────────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color        : Colors.redAccent.withOpacity(0.12),
        borderRadius : BorderRadius.circular(12),
        border       : Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width  : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color       : _saving
              ? AppColors.accent.withOpacity(0.5)
              : AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width : 20,
                  height: 20,
                  child : CircularProgressIndicator(
                    strokeWidth     : 2,
                    valueColor      : AlwaysStoppedAnimation(Color(0xFF1A0F08)),
                  ),
                )
              : Text(
                  _isEdit ? 'Update Schedule' : 'Save Schedule',
                  style: const TextStyle(
                    fontSize  : 14,
                    fontWeight: FontWeight.w700,
                    color     : Color(0xFF1A0F08),
                  ),
                ),
        ),
      ),
    );
  }

  // ── Shared card shell ─────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      padding   : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color        : AppColors.surface,
        borderRadius : BorderRadius.circular(16),
        border       : Border.all(
            color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: child,
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String                hint,
    required IconData              icon,
    TextInputType?                 keyboardType,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller  : controller,
            keyboardType: keyboardType,
            style       : const TextStyle(color: Colors.white, fontSize: 14),
            decoration  : InputDecoration(
              hintText     : hint,
              hintStyle    : TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 14),
              border       : InputBorder.none,
              isDense      : true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
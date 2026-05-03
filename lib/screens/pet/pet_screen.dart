// lib/screens/pet/pet_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';

class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petService = PetService();

    return StreamBuilder<PetModel?>(
      stream: petService.petStream(),
      builder: (context, snapshot) {
        final pet = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, pet),
                  const SizedBox(height: 20),
                  _buildPetCard(context, pet),
                  const SizedBox(height: 14),
                  _buildStatsRow(pet),
                  const SizedBox(height: 14),
                  _buildFeedingHistory(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, PetModel? pet) {
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
            const Text('My Pet',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
        // Edit button
        GestureDetector(
          onTap: () {
            if (pet != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPetScreen(pet: pet),
                ),
              );
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Icon(Icons.edit_outlined,
                size: 16, color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  // ── Pet card ───────────────────────────────────────────────────────────────

  Widget _buildPetCard(BuildContext context, PetModel? pet) {
    final name    = pet?.name    ?? 'Loading...';
    final species = pet?.species ?? 'cat';
    final emoji   = pet?.emoji   ?? '🐾';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.25), width: 1.5),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  species == 'cat' ? 'Cat' : 'Dog',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.4)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Healthy',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.greenAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(PetModel? pet) {
    final weight    = pet != null ? '${pet.weight}kg'     : '--';
    final dailyFood = pet != null ? '${pet.dailyFood}g'   : '--';

    return Row(
      children: [
        _StatCard(
          icon: Icons.monitor_weight_outlined,
          iconColor: const Color(0xFF7CB9E8),
          label: 'Weight',
          value: weight,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.restaurant_outlined,
          iconColor: AppColors.accent,
          label: 'Daily food',
          value: dailyFood,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.cake_outlined,
          iconColor: const Color(0xFFB07CE8),
          label: 'Meals today',
          value: '3',  // TODO: wire to real schedule data
        ),
      ],
    );
  }

  // ── Feeding history ────────────────────────────────────────────────────────

  Widget _buildFeedingHistory() {
    // TODO: wire to real feeding history from Firestore
    final history = [
      _FeedLog(time: '07:00 AM', grams: 20, label: 'Morning meal',   delivered: true),
      _FeedLog(time: '12:00 PM', grams: 20, label: 'Midday meal',    delivered: true),
      _FeedLog(time: '06:00 PM', grams: 20, label: 'Evening meal',   delivered: false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's feeding",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('See all',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent.withOpacity(0.8))),
            ],
          ),
          const SizedBox(height: 14),
          ...history.map((h) => _FeedLogTile(log: h)),
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}

// ── Feed log tile ──────────────────────────────────────────────────────────────

class _FeedLog {
  final String time;
  final int grams;
  final String label;
  final bool delivered;
  const _FeedLog({
    required this.time,
    required this.grams,
    required this.label,
    required this.delivered,
  });
}

class _FeedLogTile extends StatelessWidget {
  final _FeedLog log;
  const _FeedLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final color = log.delivered
        ? Colors.greenAccent.shade400
        : Colors.white.withOpacity(0.25);
    final bg = log.delivered
        ? Colors.greenAccent.withOpacity(0.12)
        : Colors.white.withOpacity(0.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(
              log.delivered ? Icons.check_rounded : Icons.access_time_rounded,
              color: color, size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: log.delivered
                            ? Colors.white
                            : Colors.white.withOpacity(0.4))),
                Text(
                  '${log.time} · ${log.grams}g · '
                  '${log.delivered ? "Delivered" : "Upcoming"}',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white
                          .withOpacity(log.delivered ? 0.35 : 0.2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Pet Screen ────────────────────────────────────────────────────────────

class EditPetScreen extends StatefulWidget {
  final PetModel pet;
  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _foodController;
  late String _species;
  bool _isLoading = false;

  final _petService = PetService();

  @override
  void initState() {
    super.initState();
    _nameController   = TextEditingController(text: widget.pet.name);
    _weightController = TextEditingController(text: widget.pet.weight.toString());
    _foodController   = TextEditingController(text: widget.pet.dailyFood.toString());
    _species          = widget.pet.species;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await _petService.updatePet(
        petId:    widget.pet.id,
        name:     _nameController.text.trim(),
        species:  _species,
        weight:   double.tryParse(_weightController.text) ?? widget.pet.weight,
        dailyFood: int.tryParse(_foodController.text)    ?? widget.pet.dailyFood,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pet updated'),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update pet'),
            backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08), width: 1),
                      ),
                      child: Icon(Icons.chevron_left_rounded,
                          color: Colors.white.withOpacity(0.7), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Pet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 28),

              // Avatar
              Center(
                child: Text(
                  _species == 'cat' ? '🐱' : '🐶',
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 24),

              // Form card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.07), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Name'),
                    const SizedBox(height: 8),
                    _inputField(controller: _nameController, hint: 'e.g. Luna'),
                    const SizedBox(height: 20),

                    _fieldLabel('Species'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _speciesChip('cat', '🐱', 'Cat'),
                        const SizedBox(width: 12),
                        _speciesChip('dog', '🐶', 'Dog'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Weight (kg)'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: _weightController,
                                hint: '4',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Daily food (g)'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: _foodController,
                                hint: '60',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 17, height: 17,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 17),
                  label: Text(_isLoading ? 'Saving...' : 'Save changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF1A0F08),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(label,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.6)));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _speciesChip(String value, String emoji, String label) {
    final selected = _species == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _species = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withOpacity(0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accent : Colors.white.withOpacity(0.1),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}
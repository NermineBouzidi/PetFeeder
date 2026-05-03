// lib/screens/setup/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/pet_model.dart';
import '../../providers/user_provider.dart';
import '../../services/pet_service.dart';
import '../home/main_shell.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _pageController   = PageController();
  int _currentPage        = 0;

  final _nameController   = TextEditingController();
  final _weightController = TextEditingController(text: '4');
  final _foodController   = TextEditingController(text: '60');
  String _species         = 'cat';
  bool _isLoading         = false;

  final _petService = PetService();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your pet's name")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pet = PetModel(
        id:        '',
        name:      _nameController.text.trim(),
        species:   _species,
        weight:    double.tryParse(_weightController.text) ?? 4.0,
        dailyFood: int.tryParse(_foodController.text)     ?? 60,
      );

      await _petService.savePetAndFinishOnboarding(pet);
      await context.read<UserProvider>().loadUser();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Something went wrong'),
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDots(),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildPetPage(),
                ],
              ),
            ),
            _buildBottomNav(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ── Dots ───────────────────────────────────────────────────────────────────

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Welcome page ───────────────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 200,
              color: AppColors.surface,
              child: const Center(
                child: Text('🐱🐶', style: TextStyle(fontSize: 72)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Badge
          _badge('✨  LET\'S GET STARTED'),
          const SizedBox(height: 14),

          const Text(
            'Welcome to\nWhisker 🐾',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'In just a few steps, we\'ll set up your pet and make sure your furry friend is always cared for.',
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                height: 1.6),
          ),
          const SizedBox(height: 20),

          // Checklist
          ...[
            'Add your first pet profile',
            'Connect your smart feeder',
            'Schedule the first meal',
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.greenAccent, size: 13),
                    ),
                    const SizedBox(width: 10),
                    Text(item,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Pet page ───────────────────────────────────────────────────────────────

  Widget _buildPetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _badge('STEP 1 — YOUR PET'),
          const SizedBox(height: 14),

          const Text(
            'Tell us about\nyour pet',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll personalize feeding portions and stats based on this.",
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                height: 1.6),
          ),
          const SizedBox(height: 20),

          // Form card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Name'),
                const SizedBox(height: 8),
                _inputField(
                  controller: _nameController,
                  hint: 'e.g. Luna',
                  icon: Icons.pets_rounded,
                ),
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
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: 0.5)),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6)));
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
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
          prefixIcon: icon != null
              ? Icon(icon,
                  color: AppColors.accent.withOpacity(0.6), size: 18)
              : null,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withOpacity(0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : Colors.white.withOpacity(0.1),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _currentPage > 0 ? _back : null,
            child: Row(
              children: [
                Icon(Icons.arrow_back_rounded,
                    size: 16,
                    color: _currentPage > 0
                        ? Colors.white.withOpacity(0.6)
                        : Colors.transparent),
                const SizedBox(width: 6),
                Text('Back',
                    style: TextStyle(
                        fontSize: 14,
                        color: _currentPage > 0
                            ? Colors.white.withOpacity(0.6)
                            : Colors.transparent)),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _next,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(
                      _currentPage == 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 17),
              label: Text(_isLoading
                  ? 'Saving...'
                  : _currentPage == 1
                      ? 'Finish setup'
                      : 'Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: const Color(0xFF1A0F08),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
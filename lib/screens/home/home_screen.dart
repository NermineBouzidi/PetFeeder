import 'package:app/models/pet_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/services/pet_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _petService = PetService();

  // Static sensor data — replace with DeviceService later
  final double _temperature    = 24.5;
  final double _humidity       = 58.0;
  final bool   _gasDetected    = false;
  final bool   _motorOn        = true;

  // Static meal data — replace with schedule data later
  final String _nextMealTime      = '06:00 PM';
  final String _nextMealCountdown = '2h 15min';
  final int    _nextMealGrams     = 50;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return StreamBuilder<PetModel?>(
      stream: _petService.petStream(),
      builder: (context, petSnap) {
        final pet = petSnap.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 20),
                  _buildNextMealCard(),
                  const SizedBox(height: 12),
                  _buildStatsGrid(),
                  const SizedBox(height: 12),
                  _buildTodaysMeals(),
                  const SizedBox(height: 12),
                  _buildPetCard(pet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 4),
            Text(
              '${_greeting()},\n${user?.firstName ?? 'there'} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.25,
              ),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 1),
                ),
                child: Icon(Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.5), size: 18),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Next meal card ───────────────────────────────────────────────────────────

  Widget _buildNextMealCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT MEAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nextMealTime,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'in $_nextMealCountdown · ${_nextMealGrams}g portion',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.25), width: 1),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: AppColors.accent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Feed Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF1A0F08),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_month_outlined,
                      size: 15, color: Colors.white.withOpacity(0.6)),
                  label: Text('Schedule',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                        color: Colors.white.withOpacity(0.08), width: 1),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats grid ───────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final stats = [
      _StatData(
        label: 'Temperature',
        value: '${_temperature.toStringAsFixed(1)}°C',
        icon: Icons.thermostat_outlined,
        iconColor: const Color(0xFF60a5fa),
        onTap: () {},
      ),
      _StatData(
        label: 'Humidity',
        value: '${_humidity.toStringAsFixed(0)}%',
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFF6ee7b7),
        onTap: () {},
      ),
      _StatData(
        label: 'Gas',
        value: _gasDetected ? 'Detected' : 'Normal',
        icon: Icons.air_outlined,
        iconColor:
            _gasDetected ? Colors.redAccent : const Color(0xFFB07CE8),
        badge: _gasDetected ? Colors.redAccent : null,
        onTap: () {},
      ),
      _StatData(
        label: 'Motor',
        value: _motorOn ? 'En marche' : "À l'arrêt",
        icon: Icons.settings_outlined,
        iconColor: _motorOn
            ? Colors.greenAccent.shade400
            : Colors.white.withOpacity(0.3),
        badge: _motorOn ? Colors.greenAccent.shade400 : null,
        onTap: () {},
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: stats.map((s) => _StatCard(data: s)).toList(),
    );
  }

  // ── Today's meals ────────────────────────────────────────────────────────────

  Widget _buildTodaysMeals() {
    final meals = [
      _MealLog(
          time: '07:00 AM',
          grams: 50,
          label: 'Morning meal',
          status: _MealStatus.delivered),
      _MealLog(
          time: '12:00 PM',
          grams: 50,
          label: 'Midday meal',
          status: _MealStatus.upcoming),
      _MealLog(
          time: '06:00 PM',
          grams: 50,
          label: 'Evening meal',
          status: _MealStatus.scheduled),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's meals",
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
          ...meals.map((m) => _MealLogTile(meal: m)),
        ],
      ),
    );
  }

  // ── Pet card ─────────────────────────────────────────────────────────────────

  Widget _buildPetCard(PetModel? pet) {
    final name    = pet?.name    ?? 'Loading...';
    final emoji   = pet?.emoji   ?? '🐾';
    final species = pet?.species == 'dog' ? 'Dog' : 'Cat';
    final weight  = pet != null  ? '${pet.weight}kg' : '--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.accent.withOpacity(0.2), width: 1),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text('$species · $weight',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.2), width: 1),
            ),
            child: const Text('Healthy',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? badge;
  final VoidCallback onTap;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.badge,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: data.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.iconColor, size: 16),
                ),
                if (data.badge != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: data.badge,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.value,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(data.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meal log ──────────────────────────────────────────────────────────────────

enum _MealStatus { delivered, upcoming, scheduled }

class _MealLog {
  final String time;
  final int grams;
  final String label;
  final _MealStatus status;
  const _MealLog({
    required this.time,
    required this.grams,
    required this.label,
    required this.status,
  });
}

class _MealLogTile extends StatelessWidget {
  final _MealLog meal;
  const _MealLogTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    final isDelivered = meal.status == _MealStatus.delivered;
    final isUpcoming  = meal.status == _MealStatus.upcoming;

    final iconColor = isDelivered
        ? Colors.greenAccent.shade400
        : isUpcoming
            ? AppColors.accent
            : Colors.white.withOpacity(0.25);

    final iconBg = isDelivered
        ? Colors.greenAccent.withOpacity(0.12)
        : isUpcoming
            ? AppColors.accent.withOpacity(0.12)
            : Colors.white.withOpacity(0.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
              isDelivered
                  ? Icons.check_rounded
                  : Icons.access_time_rounded,
              color: iconColor,
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDelivered || isUpcoming
                            ? Colors.white
                            : Colors.white.withOpacity(0.4))),
                Text(
                  '${meal.time} · ${meal.grams}g · '
                  '${isDelivered ? "Delivered" : isUpcoming ? "Upcoming" : "Scheduled"}',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(
                          isDelivered || isUpcoming ? 0.35 : 0.2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
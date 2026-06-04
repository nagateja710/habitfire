import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:habitfire/app/utils/iconcolors.dart";
import '../../../models/habit.dart';
import 'package:habitfire/app/utils/helper.dart';
class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  String dateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  // 1. CURRENT STREAK
  int currentStreak(Habit habit) {
    int streak = 0;
    DateTime day = DateTime.now();

    while (true) {
      if (!habit.activeDays.contains(day.weekday)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }

      final count = habit.dailyCounts[dateKey(day)] ?? 0;

      if (count > 0) {
        streak++;
      } else {
        if (day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day) {
          day = day.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // 2. BEST STREAK
  int bestStreak(Habit habit) {
    if (habit.dailyCounts.isEmpty) return 0;

    int best = 0;
    int current = 0;

    final completedDays = habit.dailyCounts.entries
        .where((e) => e.value > 0)
        .map((e) {
          final p = e.key.split('-');
          return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        })
        .toSet();

    if (completedDays.isEmpty) return 0;

    final sorted = completedDays.toList()..sort();
    DateTime day = sorted.first;
    DateTime end = sorted.last;

    while (!day.isAfter(end)) {
      if (habit.activeDays.contains(day.weekday)) {
        final completed = completedDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );

        if (completed) {
          current++;
          if (current > best) best = current;
        } else {
          current = 0;
        }
      }
      day = day.add(const Duration(days: 1));
    }

    return best;
  }

  // 3. PERSONAL RECORD (Best Peak)
  int personalRecord(Habit habit) {
    if (habit.dailyCounts.isEmpty) return 0;
    return habit.dailyCounts.values.reduce((a, b) => a > b ? a : b);
  }

  // 4. TODAY COUNT
  int todayCount(Habit habit) {
    return habit.dailyCounts[dateKey(DateTime.now())] ?? 0;
  }

  // 5. DAILY AVERAGE
  double dailyAverage(Habit habit) {
    if (habit.dailyCounts.isEmpty) return 0.0;
    int total = habit.dailyCounts.values.fold(0, (sum, item) => sum + item);
    return total / habit.dailyCounts.length;
  }

  IconData _getStreakIcon(int current) {
    if (current >= 1000) return Icons.workspace_premium;
    if (current >= 730) return Icons.auto_awesome;
    if (current >= 365) return Icons.celebration;
    if (current >= 200) return Icons.diamond;
    if (current >= 100) return Icons.military_tech;
    if (current >= 90) return Icons.bolt;
    if (current >= 60) return Icons.star;
    if (current >= 30) return Icons.star_half;
    if (current >= 14) return Icons.local_fire_department;
    if (current >= 10) return Icons.local_fire_department_outlined;
    if (current >= 7) return Icons.trending_up;
    return Icons.auto_awesome_outlined;
  }

  Color _getStreakColor(int current) {
    if (current >= 1000) return Colors.purple.shade700;
    if (current >= 730) return Colors.pink.shade600;
    if (current >= 365) return Colors.yellow.shade700;
    if (current >= 200) return Colors.cyan.shade600;
    if (current >= 100) return Colors.indigo.shade600;
    if (current >= 90) return Colors.yellow.shade600;
    if (current >= 60) return Colors.yellow.shade600;
    if (current >= 30) return Colors.blue.shade600;
    if (current >= 14) return Colors.orange.shade900;
    if (current >= 10) return Colors.yellow.shade600;
    if (current >= 7) return Colors.green.shade400;
    return Colors.yellow.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.insights),
            SizedBox(width: 8),
            Text("Streaks & Peaks"),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = HabitFilters.active(box.values.toList());

          if (habits.isEmpty) {
            return const Center(
              child: Text("No habits yet", style: TextStyle(fontSize: 18)),
            );
          }

          // Find the top performer for Streaks
          final streakHabits = List<Habit>.from(habits)
            ..sort((a, b) => currentStreak(b).compareTo(currentStreak(a)));
          final topStreakHabit = streakHabits.first;

          // Find the top performer for Personal Record Peaks
          final peakHabits = List<Habit>.from(habits)
            ..sort((a, b) => personalRecord(b).compareTo(personalRecord(a)));
          final topPeakHabit = peakHabits.first;

          // Main list sorted by current active streak
          final sortedHabits = streakHabits;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // TWO HIGHLIGHT HERO CARDS (Side-by-Side Layout)
              Row(
                children: [
                  // 1. STREAK LEADER
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Streak Leader",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topStreakHabit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${currentStreak(topStreakHabit)} Days",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 2. PEAK RECORD LEADER
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "All-Time Peak",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topPeakHabit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${personalRecord(topPeakHabit)} logs",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // DETAILED HABIT LIST (With Expanded Watermarked Background Icon)
              ...sortedHabits.map((habit) {
                final current = currentStreak(habit);
                final best = bestStreak(habit);
                final record = personalRecord(habit);
                final today = todayCount(habit);
                final avg = dailyAverage(habit);
                final themeColor = _getStreakColor(current);
                final iconn = habit.iconCodePoint;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // Anti-alias clipping prevents the expanded background icon from leaking past rounded borders
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // BACKDROP WATERMARK LAYER
                      Positioned(
                        right: -15,
                        bottom: -25,
                        child: Opacity(
                          opacity:
                              0.2, // Keeps it incredibly subtle to protect layout text legibility
                          child: Icon(
                            _getStreakIcon(current),
                            size: 170,
                            color: themeColor,
                          ),
                        ),
                      ),

                      // CONTENT LAYER
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: iconColorMap[iconn]?.withOpacity(0.12) ?? Colors.grey.shade300.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: iconColorMap[iconn]?.withOpacity(0.4) ?? Colors.grey.shade300.withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    IconData(
                                      iconn,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: iconColorMap[iconn] ?? Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Logged Today: $today ${today == 1 ? 'time' : 'times'}",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$current",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "streak",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Divider(height: 24),

                            // Bottom Grid Metrics
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetricItem(
                                  "Best Streak",
                                  "$best days",
                                  Icons.workspace_premium,
                                ),
                                _buildMetricItem(
                                  "Personal Record",
                                  "$record logs",
                                  Icons.bolt,
                                ),
                                _buildMetricItem(
                                  "Daily Average",
                                  avg.toStringAsFixed(1),
                                  Icons.functions,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

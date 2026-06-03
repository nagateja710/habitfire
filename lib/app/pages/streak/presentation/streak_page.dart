import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/habit.dart';

class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  String dateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  int currentStreak(Habit habit) {
    int streak = 0;
    DateTime day = DateTime.now();

    while (true) {
      if (!habit.activeDays.contains(day.weekday)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }

      if ((habit.dailyCounts[dateKey(day)] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int bestStreak(Habit habit) {
    if (habit.dailyCounts.isEmpty) {
      return 0;
    }

    int best = 0;
    int current = 0;

    final completedDays = habit.dailyCounts.entries
        .where((e) => e.value > 0)
        .map((e) {
      final p = e.key.split('-');

      return DateTime(
        int.parse(p[0]),
        int.parse(p[1]),
        int.parse(p[2]),
      );
    }).toSet();

    if (completedDays.isEmpty) {
      return 0;
    }

    final sorted = completedDays.toList()
      ..sort();

    DateTime day = sorted.first;
    DateTime end = sorted.last;

    while (!day.isAfter(end)) {
      if (habit.activeDays.contains(day.weekday)) {
        final completed = completedDays.any(
          (d) =>
              d.year == day.year &&
              d.month == day.month &&
              d.day == day.day,
        );

        if (completed) {
          current++;
          if (current > best) {
            best = current;
          }
        } else {
          current = 0;
        }
      }

      day = day.add(const Duration(days: 1));
    }

    return best;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Streaks"),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text(
                "No habits yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          habits.sort(
            (a, b) =>
                currentStreak(b)
                    .compareTo(currentStreak(a)),
          );

          final topHabit = habits.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "🏆 Top Performer",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        topHabit.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${currentStreak(topHabit)} Day Streak",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ...habits.map((habit) {
                final current =
                    currentStreak(habit);

                final best =
                    bestStreak(habit);

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(
                      16,
                    ),
                    leading: Text(
                      current >= 30
                          ? "🔥"
                          : current >= 7
                              ? "🔥"
                              : "✨",
                      style:
                          const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      "Best: $best days",
                    ),
                    trailing: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          "$current",
                          style:
                              const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const Text(
                          "days",
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:habitfire/app/models/habit.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  String dateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  int currentStreak(Habit habit) {
    int streak = 0;
    DateTime day = DateTime.now();

    while (true) {
      final key = dateKey(day);

      if ((habit.dailyCounts[key] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

int bestStreak(Habit habit) {
  final completedDates = habit.dailyCounts.entries
      .where((e) => e.value > 0)
      .map((e) {
        final p = e.key.split('-');
        return DateTime(
          int.parse(p[0]),
          int.parse(p[1]),
          int.parse(p[2]),
        );
      })
      .toSet();

  if (completedDates.isEmpty) return 0;

  final sorted = completedDates.toList()
    ..sort();

  int best = 0;
  int current = 0;

  DateTime day = sorted.first;
  DateTime end = sorted.last;

  while (!day.isAfter(end)) {
    if (habit.activeDays.contains(day.weekday)) {
      if (completedDates.any((d) =>
          d.year == day.year &&
          d.month == day.month &&
          d.day == day.day)) {
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

Widget statCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final habitsBox = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: ValueListenableBuilder(
        valueListenable: habitsBox.listenable(),
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

          final today = DateTime.now();

          final todaysHabits = habits.where(
            (h) => h.activeDays.contains(today.weekday),
          ).toList();

          final completedToday = todaysHabits.where(
            (h) =>
                (h.dailyCounts[dateKey(today)] ?? 0) > 0,
          ).length;

          final completionRate =
              todaysHabits.isEmpty
                  ? 0.0
                  : completedToday /
                      todaysHabits.length *
                      100;

          int combinedStreak = 0;
          int longestStreak = 0;

          Habit? mostConsistent;
          int maxCompletedDays = 0;

          final categoryCounts = <String, int>{};

          for (final habit in habits) {
            final streak = currentStreak(habit);

            combinedStreak += streak;

            final best = bestStreak(habit);

            if (best > longestStreak) {
              longestStreak = best;
            }

            final completedDays = habit
                .dailyCounts.values
                .where((v) => v > 0)
                .length;

            if (completedDays >
                maxCompletedDays) {
              maxCompletedDays = completedDays;
              mostConsistent = habit;
            }

            categoryCounts[habit.category] =
                (categoryCounts[habit.category] ??
                        0) +
                    1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: 
            Column(
             children: [
              GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  childAspectRatio: 1.25,
  children: [
    statCard(
      "Total Habits",
      habits.length.toString(),
      Icons.track_changes,
      Colors.green,
    ),

    statCard(
      "Scheduled Today",
      todaysHabits.length.toString(),
      Icons.today,
      Colors.blue,
    ),

    statCard(
      "Completed Today",
      "$completedToday / ${todaysHabits.length}",
      Icons.check_circle,
      Colors.green,
    ),

    statCard(
      "Completion",
      "${completionRate.round()}%",
      Icons.pie_chart,
      Colors.deepPurple,
    ),

    statCard(
      "Combined Streak",
      "$combinedStreak",
      Icons.local_fire_department,
      Colors.orange,
    ),

    statCard(
      "Best Streak",
      "$longestStreak",
      Icons.emoji_events,
      Colors.amber,
    ),
  ],
),
                const SizedBox(height: 25),

                if (mostConsistent != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      title: const Text(
                        "Most Consistent Habit",
                      ),
                      subtitle: Text(
                        mostConsistent.title,
                      ),
                      trailing: Text(
                        "$maxCompletedDays days",
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...categoryCounts.entries
                            .map(
                          (entry) => Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                  ),
                                ),
                                Text(
                                  entry.value
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          
          );
        },
      ),
    );
  }
}
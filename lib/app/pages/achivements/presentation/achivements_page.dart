import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:habitfire/app/models/habit.dart';
import 'package:habitfire/app/utils/helper.dart';
import 'package:habitfire/app/utils/iconcolors.dart';

DateTime _actualStartDate(Habit habit) {
  if (habit.dailyCounts.isEmpty) {
    return habit.createdAt;
  }

  final dates = habit.dailyCounts.entries.where((e) => e.value > 0).map((e) {
    final p = e.key.split('-');

    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }).toList();

  if (dates.isEmpty) {
    return habit.createdAt;
  }

  dates.sort();

  return dates.first;
}

DateTime _actualEndDate(Habit habit) {
  if (habit.dailyCounts.isEmpty) {
    return habit.createdAt;
  }

  final dates = habit.dailyCounts.entries.where((e) => e.value > 0).map((e) {
    final p = e.key.split('-');

    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }).toList();

  if (dates.isEmpty) {
    return habit.createdAt;
  }

  dates.sort();

  return dates.last;
}

Widget _infoTile(IconData icon, String label, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white.withOpacity(0.05),
    ),
    child: Column(
      children: [
        Icon(icon, size: 18),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.star,color: Colors.yellow),
            const SizedBox(width: 8),
            const Text('Journeys'),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, _, __) {
          final achievements = HabitFilters.achievements(box.values.toList());

          achievements.sort(
            (a, b) => (b.achievedAt ?? DateTime.now()).compareTo(
              a.achievedAt ?? DateTime.now(),
            ),
          );

          if (achievements.isEmpty) {
            return const _EmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryGrid(achievements: achievements),

                const SizedBox(height: 20),

                const Text(
                  'Completed Journeys',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...achievements.map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(habit.id),

                      // RESTORE
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restore_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      // DELETE
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      confirmDismiss: (direction) async {
                        // RESTORE TO ACTIVE
                        if (direction == DismissDirection.startToEnd) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Restore Habit?'),
                              content: Text(
                                "Move '${habit.title}' back to active habits?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Restore'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            habit.isAchieved = false;
                            habit.achievedAt = null;

                            await habit.save();

                            return true;
                          }

                          return false;
                        }

                        // DELETE FOREVER
                        if (direction == DismissDirection.endToStart) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Journey?'),
                              content: Text(
                                "Delete '${habit.title}' permanently?\n\nThis cannot be undone.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await habit.delete();
                            return true;
                          }

                          return false;
                        }

                        return false;
                      },

                      child: _AchievementCard(habit: habit),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<Habit> achievements;

  const _SummaryGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final totalAchievements = achievements.length;

    final totalDaysInvested = achievements.fold<int>(
      0,
      (sum, h) => sum + _durationDays(h),
    );

    final longestJourney = achievements.isEmpty
        ? 0
        : achievements.map(_durationDays).reduce(max);

    final bestCompletionRate = achievements.isEmpty
        ? 0
        : achievements.map(_completionRate).reduce(max).round();

    final categoriesCompleted = achievements
        .map((e) => e.category)
        .toSet()
        .length;

    final totalLogs = achievements.fold<int>(
      0,
      (sum, h) => sum + _totalCompletions(h),
    );

    final stats = [
      [
        Icons.emoji_events_rounded,
        'Achievements',
        '$totalAchievements',
        Colors.amber,
      ],
      [
        Icons.schedule_rounded,
        'Days Invested',
        '$totalDaysInvested',
        Colors.blue,
      ],
      [
        Icons.local_fire_department_rounded,
        'Longest Journey',
        '$longestJourney',
        Colors.orange,
      ],
      [
        Icons.trending_up_rounded,
        'Best Rate',
        '$bestCompletionRate%',
        Colors.green,
      ],
      [
        Icons.category_rounded,
        'Categories',
        '$categoriesCompleted',
        Colors.purple,
      ],
      [
        Icons.check_circle_rounded,
        'Completed Logs',
        '$totalLogs',
        Colors.green,
      ],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stats[index][0] as IconData,
                  size: 30,
                  color: stats[index][3] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  stats[index][2] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats[index][1] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Habit habit;

  const _AchievementCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final duration = _durationDays(habit);
    final completions = _totalCompletions(habit);
    final streak = _bestStreak(habit);
    final completionRate = _completionRate(habit).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            /// TOP SECTION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color:
                        iconColorMap[habit.iconCodePoint]?.withOpacity(0.15) ??
                        Colors.grey.withOpacity(0.15),
                  ),
                  child: Icon(
                    IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: iconColorMap[habit.iconCodePoint] ?? Colors.grey,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        habit.category,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // color: Colors.orange.withOpacity(0.12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '$streak',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 20,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const Text('Best Streak', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Divider(),

            const SizedBox(height: 10),

            /// BOTTOM TIMELINE
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd MMM').format(_actualStartDate(habit)),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Started'),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        '$duration Days  $completions Logs',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Container(height: 2, color: Colors.grey.withOpacity(0.3)),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd MMM').format(habit.achievedAt!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Finished'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 1),

            Text(
              '$completionRate% completion rate',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emoji_events_outlined, size: 72),
            SizedBox(height: 16),
            Text(
              'No Achievements Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Retire a habit by selecting\n'
              '"Move to Achievements".\n\n'
              'Your completed journeys\n'
              'will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

int _durationDays(Habit habit) {
  if (habit.achievedAt == null) return 0;
  final startDate = _actualStartDate(habit);
  final endDate = _actualEndDate(habit).isBefore(habit.achievedAt!) ? _actualEndDate(habit) : habit.achievedAt!;
  return endDate.difference(startDate).inDays + 1;
  // return habit.achievedAt!
  //         .difference(habit.createdAt)
  //         .inDays +
  //     1;
}

int _totalCompletions(Habit habit) {
  return habit.dailyCounts.values.fold(0, (sum, value) => sum + value);
}

double _completionRate(Habit habit) {
  final duration = _durationDays(habit);

  if (duration == 0) return 0;

  final completions = _totalCompletions(habit);

  return ((completions / duration) * 100).clamp(0, 100);
}

int _bestStreak(Habit habit) {
  final completedDates =
      habit.dailyCounts.entries.where((e) => e.value > 0).map((e) {
        final parts = e.key.split('-');

        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }).toList()..sort();

  if (completedDates.isEmpty) {
    return 0;
  }

  int best = 1;
  int current = 1;

  for (int i = 1; i < completedDates.length; i++) {
    final diff = completedDates[i].difference(completedDates[i - 1]).inDays;

    if (diff == 1) {
      current++;
      best = max(best, current);
    } else {
      current = 1;
    }
  }

  return best;
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:habitfire/app/models/habit.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Loading...";

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      version = "${info.version}+${info.buildNumber}";
    });
  }

  Future<void> openGithub() async {
    final uri = Uri.parse(
      'https://github.com/nagateja710/habitfire',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  int calculateLongestStreak(Habit habit) {
    int best = 0;
    int current = 0;

    final entries = habit.dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in entries) {
      if (entry.value > 0) {
        current++;
        if (current > best) {
          best = current;
        }
      } else {
        current = 0;
      }
    }

    return best;
  }

  @override
  Widget build(BuildContext context) {
    final habits = Hive.box<Habit>('habits').values.toList();

    final totalHabits = habits.length;

    final totalCompletions = habits.fold(
      0,
      (sum, habit) =>
          sum +
          habit.dailyCounts.values.fold(
            0,
            (a, b) => a + b,
          ),
    );

    int longestStreak = 0;

    for (final habit in habits) {
      final streak = calculateLongestStreak(habit);

      if (streak > longestStreak) {
        longestStreak = streak;
      }
    }

    DateTime? oldestHabit;

    if (habits.isNotEmpty) {
      oldestHabit = habits
          .map((h) => h.createdAt)
          .reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
    }

    final daysTracking = oldestHabit == null
        ? 0
        : DateTime.now()
            .difference(oldestHabit)
            .inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About HabitFire"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 65,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "HabitFire",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Build habits. Protect your streak.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text(
                          "Your Statistics",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _statTile(
                      "Total Habits",
                      totalHabits.toString(),
                    ),

                    _statTile(
                      "Total Completions",
                      totalCompletions.toString(),
                    ),

                    _statTile(
                      "Longest Streak",
                      "$longestStreak days",
                    ),

                    _statTile(
                      "Days Tracking",
                      daysTracking.toString(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: const [
        Icon(
          Icons.local_fire_department,
          color: Colors.deepOrange,
          size: 40,
        ),

        SizedBox(height: 12),

        Text(
          "Why HabitFire?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Text(
           "Small actions repeated consistently create remarkable results. HabitFire helps you stay accountable and keep your streak alive every day.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text(
                      "GitHub Repository",
                    ),
                    subtitle: const Text(
                      "View source code",
                    ),
                    trailing:
                        const Icon(Icons.open_in_new),
                    onTap: openGithub,
                  ),
                ],
              ),
            ),



            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: const Text(
                      "Developer",
                    ),
                    subtitle:
                        const Text("Naga Teja"),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.info),
                    title:
                        const Text("Version"),
                    subtitle: Text(version),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(
                      Icons.format_quote,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Consistency beats motivation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "🔥 Keep the fire burning.",
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statTile(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
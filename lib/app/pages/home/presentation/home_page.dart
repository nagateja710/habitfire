import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitfire/app/utils/edit_habit_dialog.dart';
import 'package:habitfire/app/models/habit.dart';
import 'package:habitfire/app/widgets/habit_card.dart';
import 'package:habitfire/app/pages/addhabit/presentation/add_habit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Habit> habitsBox;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    habitsBox = Hive.box<Habit>('habits');
  }

  bool isToday() {
    final now = DateTime.now();

    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  String get dateKey =>
      "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

  Future<void> addHabit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddHabitPage(),
      ),
    );

    setState(() {});
  }

  void goToPreviousDay() {
    setState(() {
      selectedDate =
          selectedDate.subtract(const Duration(days: 1));
    });
  }

  void goToNextDay() {
    if (isToday()) return;

    setState(() {
      selectedDate =
          selectedDate.add(const Duration(days: 1));
    });
  }

  int calculateStreak(Habit habit) {
    int streak = 0;

    DateTime current = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    while (true) {
      // Skip non-scheduled days
      if (!habit.activeDays.contains(current.weekday)) {
        current =
            current.subtract(const Duration(days: 1));
        continue;
      }

      final key =
          "${current.year}-${current.month}-${current.day}";

      final count = habit.dailyCounts[key] ?? 0;

      if (count > 0) {
        streak++;
        current =
            current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// HEADER
              // Row(
              //   mainAxisAlignment:
              //       MainAxisAlignment.spaceBetween,
              //   children: [
              //     RichText(
              //       text: const TextSpan(
              //         style: TextStyle(
              //           fontSize: 34,
              //           fontWeight: FontWeight.bold,
              //         ),
              //         children: [
              //           TextSpan(
              //             text: 'HABIT',
              //             style: TextStyle(
              //               color: Colors.red,
              //             ),
              //           ),
              //           TextSpan(
              //             text: 'FIRE',
              //             style: TextStyle(
              //               color: Color.fromRGBO(
              //                 249,
              //                 168,
              //                 37,
              //                 1,
              //               ),
              //             ),
              //           ),
              //           WidgetSpan(
              //             alignment:
              //                 PlaceholderAlignment.middle,
              //             child: Icon(
              //               Icons.local_fire_department,
              //               size: 34,
              //               color: Colors.yellow,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     PopupMenuButton<String>(
              //       icon: const Icon(
              //         Icons.menu,
              //         size: 32,
              //       ),
              //       itemBuilder: (context) => const [
              //         PopupMenuItem(
              //           value: 'settings',
              //           child: Text('Settings'),
              //         ),
              //         PopupMenuItem(
              //           value: 'darkmode',
              //           child: Text('Dark Mode'),
              //         ),
              //         PopupMenuItem(
              //           value: 'about',
              //           child: Text('About'),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),

              const SizedBox(height: 30),

              /// DATE CONTROLS
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: goToPreviousDay,
                    child: const Icon(
                      Icons.chevron_left,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedDate =
                              DateTime.now();
                        });
                      },
                      child: Text(
                        isToday()
                            ? "Today"
                            : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  if (!isToday())
                    FilledButton.tonal(
                      onPressed: goToNextDay,
                      child: const Icon(
                        Icons.chevron_right,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable:
                      habitsBox.listenable(),
                  builder: (
                    context,
                    Box<Habit> box,
                    _,
                  ) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          "No habits yet.\nTap + to add one.",
                          textAlign:
                              TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: box.length,
                      itemBuilder:
                          (context, index) {
                        final habit =
                            box.getAt(index)!;

                        // Hide habit on days it is not scheduled
                        if (!habit.activeDays
                            .contains(
                              selectedDate.weekday,
                            )) {
                          return const SizedBox
                              .shrink();
                        }

                        final countForDay =
                            habit.dailyCounts[
                                    dateKey] ??
                                0;

                        final completedToday =
                            countForDay > 0;

                        final streak =
                            calculateStreak(
                              habit,
                            );

return Dismissible(
  key: ValueKey(habit.id),

  background: Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.red.shade600,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(
      Icons.delete,
      color: Colors.white,
      size: 32,
    ),
  ),

  secondaryBackground: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.blue.shade600,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(
      Icons.edit,
      color: Colors.white,
      size: 32,
    ),
  ),

  confirmDismiss: (direction) async {
    // DELETE
    if (direction == DismissDirection.startToEnd) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Habit"),
          content: Text(
            "Delete '${habit.title}'?",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Delete"),
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

    // EDIT
    if (direction == DismissDirection.endToStart) {
      await showDialog(
        context: context,
        builder: (_) =>
            EditHabitDialog(habit: habit),
      );

      return false;
    }

    return false;
  },

  child: Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: HabitCard(
      title: habit.title,
      subtitle: habit.category,
      iconCodePoint: habit.iconCodePoint,
      count: countForDay,
      streak: streak,
      completed: completedToday,

      onCountTap: () async {
        habit.dailyCounts[dateKey] =
            countForDay + 1;
        await habit.save();
      },

      onCountLongPress: () async {
        setState(() {
          habit.dailyCounts[dateKey] = 0;
        });

        await habit.save();
        Feedback.forLongPress(context);
      },
    ),
  ),
);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
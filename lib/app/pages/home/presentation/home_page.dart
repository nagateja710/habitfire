import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitfire/app/utils/edit_habit_dialog.dart';
import 'package:habitfire/app/models/habit.dart';
import 'package:habitfire/app/widgets/habit_card.dart';
import 'package:habitfire/app/pages/addhabit/presentation/add_habit_page.dart';
import 'package:habitfire/app/utils/helper.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Ensure this import is at the top of your file

Timer? _swipeHoldTimer;
bool _isThrottled = false; // Prevents the initial swipe from jumping multiple days instantly
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
      MaterialPageRoute(builder: (_) => const AddHabitPage()),
    );

    setState(() {});
  }

  void goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void goToNextDay() {
    if (isToday()) return;

    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
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
        current = current.subtract(const Duration(days: 1));
        continue;
      }

      final key = "${current.year}-${current.month}-${current.day}";

      final count = habit.dailyCounts[key] ?? 0;

      if (count > 0) {
        streak++;
        current = current.subtract(const Duration(days: 1));
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
              // const SizedBox(height: 10),

              // const SizedBox(height: 30),

              /// DATE CONTROLS
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: goToPreviousDay,
                    child: const Icon(Icons.chevron_left),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
  child: GestureDetector(
    onHorizontalDragUpdate: (details) {
      // 1. Determine direction based on delta (positive = right, negative = left)
      bool isSwipingRight = details.delta.dx > 0;
      bool isSwipingLeft = details.delta.dx < 0;

      // 2. Only start the timer if it isn't already running
      if (_swipeHoldTimer == null) {
        
        // Define the repeating action
        void tickDate() {
          DateTime today = DateTime.now();
          
          if (isSwipingRight) {
            // Swipe & Hold Right -> Continuously go to PREVIOUS day
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          } else if (isSwipingLeft) {
            // Swipe & Hold Left -> Continuously go to NEXT day (Max = Today)
            DateTime nextDay = selectedDate.add(const Duration(days: 1));
            
            if (nextDay.isBefore(today) || 
                (nextDay.year == today.year && nextDay.month == today.month && nextDay.day == today.day)) {
              setState(() {
                selectedDate = nextDay;
              });
            } else {
              // If we reached today, stop the timer early
              _swipeHoldTimer?.cancel();
              _swipeHoldTimer = null;
            }
          }
        }

        // Trigger the first day change immediately upon swipe
        tickDate(); 

        // Start repeating every 300 milliseconds while finger is held down
        // Adjust the Duration (e.g., 200ms for faster, 400ms for slower) to change scrolling speed
        _swipeHoldTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
          tickDate();
        });
      }
    },
    onHorizontalDragEnd: (details) {
      // 3. IMPORTANT: Stop the continuous ticking as soon as the finger lifts
      _swipeHoldTimer?.cancel();
      _swipeHoldTimer = null;
    },
    child: OutlinedButton(
      onPressed: () {
        setState(() {
          selectedDate = DateTime.now();
        });
      },
      child: isToday()
          ? RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: "Today",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " ${DateFormat(", EEE").format(selectedDate)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: DateFormat("d MMMM, yyyy").format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " ${DateFormat("EEE").format(selectedDate)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    ),
  ),
),
              const SizedBox(width: 12),

                  if (!isToday())
                    FilledButton.tonal(
                      onPressed: goToNextDay,
                      child: const Icon(Icons.chevron_right),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: habitsBox.listenable(),
                  builder: (context, Box<Habit> box, _) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          "No habits yet.\nTap + to add one.",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // return ListView.builder(
                    final habits = HabitFilters.active(box.values.toList());

                    return ListView.builder(
                       padding: const EdgeInsets.only(bottom: 60),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];

                        // Hide habit on days it is not scheduled
                        if (!habit.activeDays.contains(selectedDate.weekday)) {
                          return const SizedBox.shrink();
                        }

                        final countForDay = habit.dailyCounts[dateKey] ?? 0;

                        final completedToday = countForDay > 0;

                        final streak = calculateStreak(habit);

                        return Dismissible(
                          key: ValueKey(habit.id),

                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),

                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
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

                          confirmDismiss: (direction) async {
                            // DELETE
                            if (direction == DismissDirection.endToStart) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Habit"),
                                  content: Text("Delete '${habit.title}'?"),
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
                            if (direction == DismissDirection.startToEnd) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Move to Journeys?"),
                                  content: Text(
                                    "Move '${habit.title}' to Journeys?\n\n"
                                    "It will become read-only and no longer affect streaks or analytics.",
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
                                      child: const Text("Move"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                habit.isAchieved = true;
                                habit.achievedAt = DateTime.now();

                                await habit.save();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${habit.title} moved to Journeys!",
                                    ),
                                  ),
                                );

                                return true;
                              }

                              return false;
                            }

                            return false;
                          },

                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => EditHabitDialog(habit: habit),
                                );
                              },
                              child: HabitCard(
                                title: habit.title,
                                subtitle: habit.category,
                                iconCodePoint: habit.iconCodePoint,
                                count: countForDay,
                                streak: streak,
                                completed: completedToday,

                                onCountTap: () async {
                                  habit.dailyCounts[dateKey] = countForDay + 1;
                                  await habit.save();
                                },

                                onCountLongPress: () async {
                                  setState(() {
                                    // habit.dailyCounts[dateKey] = 0;
                                    habit.dailyCounts.remove(dateKey);
                                  });

                                  await habit.save();
                                  Feedback.forLongPress(context);
                                },
                              ),
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

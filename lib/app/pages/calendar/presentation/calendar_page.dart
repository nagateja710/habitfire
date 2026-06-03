import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/habit.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Box<Habit> habitsBox;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime focusedDay  = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    habitsBox = Hive.box<Habit>('habits');
  }

  String dateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Color getDayColor(DateTime day) {
    final habits = habitsBox.values.toList();

    int total = 0;
    int completed = 0;

    for (final habit in habits) {
      if (!habit.activeDays.contains(day.weekday)) {
        continue;
      }

      total++;

      if ((habit.dailyCounts[dateKey(day)] ?? 0) > 0) {
        completed++;
      }
    }

    if (total == 0) {
      return Colors.grey.shade300;
    }

    final ratio = completed / total;

    if (ratio == 1) {
      return Colors.green;
    }

    if (ratio >= 0.1) {
      return Colors.lightGreen;
    }

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: ValueListenableBuilder(
        valueListenable: habitsBox.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.toList();

          final scheduledHabits = habits.where(
            (habit) =>
                habit.activeDays.contains(selectedDay.weekday),
          ).toList();

          final completedCount = scheduledHabits.where(
            (habit) =>
                (habit.dailyCounts[dateKey(selectedDay)] ?? 0) > 0,
          ).length;

          final percent = scheduledHabits.isEmpty
              ? 0.0
              : completedCount / scheduledHabits.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
  firstDay: DateTime.utc(2024),
  lastDay: DateTime.utc(2035),
  focusedDay: focusedDay,

  calendarFormat: _calendarFormat,

  availableCalendarFormats: const {
    CalendarFormat.month: 'Week',
    CalendarFormat.twoWeeks: 'Month',
    CalendarFormat.week: '2 Weeks',
  },

  onFormatChanged: (format) {
    setState(() {
      _calendarFormat = format;
    });
  },

  headerStyle: HeaderStyle(
    titleCentered: true,
    formatButtonDecoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    formatButtonTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),

  selectedDayPredicate: (day) {
    return isSameDay(selectedDay, day);
  },

  onDaySelected: (selected, focused) {
    setState(() {
      selectedDay = selected;
      focusedDay = focused;
    });
  },

  calendarBuilders: CalendarBuilders(
    defaultBuilder: (context, day, _) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: getDayColor(day).withOpacity(.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
          ),
        ),
      );
    },

    selectedBuilder: (context, day, _) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },

    todayBuilder: (context, day, _) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  ),
),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${selectedDay.day} "
                            "${_monthName(selectedDay.month)}, "
                            "${selectedDay.year}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "$completedCount / ${scheduledHabits.length} habits completed",
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 20),

                          LinearProgressIndicator(
                            value: percent,
                            minHeight: 12,
                            borderRadius:
                                BorderRadius.circular(
                              100,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "${(percent * 100).round()}%",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // const Text(
                          //   "Completed",
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight:
                          //         FontWeight.bold,
                          //   ),
                          // ),

                          // const SizedBox(height: 12),

                          ...scheduledHabits
                              .where(
                                (habit) =>
                                    (habit.dailyCounts[
                                                dateKey(
                                                    selectedDay)] ??
                                            0) >
                                        0,
                              )
                              .map(
                                (habit) => Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    "✓ ${habit.title}",
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      color:
                                          Colors.green,
                                    ),
                                  ),
                                ),
                              ),

                          // const SizedBox(height: 24),

                          // const Text(
                          //   "Missed",
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight:
                          //         FontWeight.bold,
                          //   ),
                          // ),

                          // const SizedBox(height: 12),

                          ...scheduledHabits
                              .where(
                                (habit) =>
                                    (habit.dailyCounts[
                                                dateKey(
                                                    selectedDay)] ??
                                            0) ==
                                        0,
                              )
                              .map(
                                (habit) => Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    "✗ ${habit.title}",
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
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

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month];
  }
}
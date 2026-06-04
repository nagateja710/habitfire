import 'package:habitfire/app/models/habit.dart';

class HabitFilters {
  static List<Habit> active(List<Habit> habits) {
    return habits
        .where((h) => !(h.isAchieved ?? false))
        .toList();
  }

  static List<Habit> achievements(List<Habit> habits) {
    return habits
        .where((h) => h.isAchieved ?? false)
        .toList();
  }
}
// int calculateStreak(Habit habit) {
//   final today = DateTime.now();

//   int streak = 0;
//   DateTime current = DateTime(
//     today.year,
//     today.month,
//     today.day,
//   );

//   while (true) {
//     // Skip days that are not part of the habit schedule
//     if (!habit.activeDays.contains(current.weekday)) {
//       current = current.subtract(const Duration(days: 1));
//       continue;
//     }

//     final key =
//         '${current.year.toString().padLeft(4, '0')}-'
//         '${current.month.toString().padLeft(2, '0')}-'
//         '${current.day.toString().padLeft(2, '0')}';

//     final count = habit.dailyCounts[key] ?? 0;

//     if (count > 0) {
//       streak++;
//       current = current.subtract(const Duration(days: 1));
//     } else {
//       break;
//     }
//   }

//   return streak;
// }
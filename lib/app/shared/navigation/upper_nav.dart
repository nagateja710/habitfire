import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitfire/app/app.dart';
import 'package:habitfire/app/pages/about/presentation/about.dart';
import 'package:habitfire/app/utils/backup_service.dart';
import 'package:habitfire/app/models/habit.dart';

class UpperNav extends StatelessWidget implements PreferredSizeWidget {
  const UpperNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Removes default back button space if needed, or handles it automatically
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Your custom Row goes into the title property
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'HABIT',
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: 'FIRE',
                  style: TextStyle(color: Color.fromRGBO(249, 168, 37, 1)),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 34,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, size: 32),

            onSelected: (value) async {
              switch (value) {
                case 'darkmode':
                  themeNotifier.value = themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                  break;

                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                  break;

                case 'export':
                  final msg = await BackupService.exportJson();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                  break;

                case 'import':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Restore Backup?"),
                      content: const Text(
                        "This will replace all existing habits and progress.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Restore"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final msg = await BackupService.importJson();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                  break;
                case 'reset':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                      title: const Text("Reset All Data?"),
                      content: const Text(
                        "This will permanently delete all habits, streaks, and progress.\n\nThis action cannot be undone.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete Everything"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  await Hive.box<Habit>('habits').clear();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All HabitFire data has been removed."),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'export', child: Text('Export Backup')),
              PopupMenuItem(value: 'import', child: Text('Import Backup')),
              PopupMenuItem(value: 'darkmode', child: Text('Toggle Dark Mode')),
              PopupMenuItem(value: 'about', child: Text('About')),
              PopupMenuItem(value: 'reset', child: Text('Reset All Data')),
            ],
          ),
        ],
      ),
    );
  }

  // This defines the height of your header area
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

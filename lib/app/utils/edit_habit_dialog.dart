import 'package:flutter/material.dart';
import 'package:habitfire/app/models/habit.dart';

class EditHabitDialog extends StatefulWidget {
  final Habit habit;

  const EditHabitDialog({super.key, required this.habit});

  @override
  State<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  late TextEditingController controller;

  late List<int> selectedDays;

  final days = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.habit.title);

    selectedDays = List.from(widget.habit.activeDays);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Habit"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Habit Name"),
            ),

            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 2,
              children: List.generate(7, (index) {
                final day = index + 1;
                final selected = selectedDays.contains(day);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        days[index],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 4),

                      AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: selected ? 1.1 : 1,
                        child: Icon(
                          selected
                              ? Icons.local_fire_department
                              : Icons.local_fire_department_outlined,
                          size: 34,
                          color: selected
                              ? Colors.orange
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: () async {
                    widget.habit.title = controller.text.trim();

                    widget.habit.activeDays = selectedDays;

                    await widget.habit.save();

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),

            // const SizedBox(height: 4),
            const SizedBox(height: 2),

            const Divider(),

            const SizedBox(height: 2),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Habit"),
                        content: Text("Delete '${widget.habit.title}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          //hor divider
                          // Container(
                          //   height: 2,
                          //   width: 20,
                          //   color: Colors.grey.shade300,
                          // ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await widget.habit.delete();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),

                const SizedBox(width: 8),

                TextButton.icon(
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.orange,
                    size: 18,
                  ),
                  label: const Text(
                    "Move to Journeys",
                    style: TextStyle(color: Colors.orange),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Move to Journeys?"),
                        content: Text(
                          "Move '${widget.habit.title}' to Journeys?\n\n"
                          "It will no longer affect analytics and streaks.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Move to Journeys"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      widget.habit.isAchieved = true;
                      widget.habit.achievedAt = DateTime.now();

                      await widget.habit.save();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

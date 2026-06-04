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
  spacing: 16,
  runSpacing: 12,
  children: List.generate(
    7,
    (index) {
      final day = index + 1;
      final selected =
          selectedDays.contains(day);

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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            AnimatedScale(
              duration: const Duration(
                milliseconds: 150,
              ),
              scale: selected ? 1.1 : 1,
              child: Icon(
                selected ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                size: 34,
                color: selected
                    ? Colors.orange
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    },
  ),
),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
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
    );
  }
}

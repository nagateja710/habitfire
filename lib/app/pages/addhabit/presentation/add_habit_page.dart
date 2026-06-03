import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:habitfire/app/models/habit.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController nameController =
      TextEditingController();

  String selectedCategory = 'Health';

  IconData selectedIcon = Icons.water_drop;

  final categories = const [
    'Health',
    'Fitness',
    'Study',
    'Work',
    'Reading',
    'Meditation',
    'Nutrition',
    'Finance',
    'Personal',
    'Other',
  ];

  final icons = const [
    Icons.water_drop,
    Icons.fitness_center,
    Icons.book,
    Icons.self_improvement,
    Icons.run_circle,
    Icons.restaurant,
    Icons.local_fire_department,
    Icons.savings,
    Icons.school,
    Icons.work,
    Icons.code,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.bed,
    Icons.favorite,
    Icons.star,
    Icons.lightbulb,
    Icons.psychology,
    Icons.spa,
    Icons.local_drink,
    Icons.directions_walk,
    Icons.monitor_heart,
    Icons.fastfood,
    Icons.laptop,
    Icons.timer,
    Icons.pets,
    Icons.language,
    Icons.travel_explore,
    Icons.cleaning_services,
    Icons.check_circle,
  ];

  Future<void> saveHabit() async {
    if (nameController.text.trim().isEmpty) return;

    final box = Hive.box<Habit>('habits');

    await box.add(
      Habit(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        title: nameController.text.trim(),
        category: selectedCategory,
        iconCodePoint: selectedIcon.codePoint,
        createdAt: DateTime.now(),
        dailyCounts: {},
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Habit Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter habit name',
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Choose Icon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: icons.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (context, index) {
                final icon = icons[index];

                final selected =
                    icon.codePoint ==
                        selectedIcon.codePoint;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIcon = icon;
                    });
                  },
                  child: Card(
                    color: selected
                        ? Colors.green.shade100
                        : null,
                    child: Icon(icon),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            FilledButton(
              onPressed: saveHabit,
              child: const Text(
                'Create Habit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:habitfire/app/models/habit.dart';

class HabitIcon {
  final IconData icon;
  final Color color;

  const HabitIcon(this.icon, this.color);
}

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController nameController = TextEditingController();

  String selectedCategory = 'Health';

  HabitIcon selectedIcon = const HabitIcon(Icons.water_drop, Colors.blue);

  List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7];

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

  final weekDays = const [
    ('M', 1),
    ('T', 2),
    ('W', 3),
    ('T', 4),
    ('F', 5),
    ('S', 6),
    ('S', 7),
  ];

  final icons = const [
    HabitIcon(Icons.water_drop, Colors.blue),
    HabitIcon(Icons.fitness_center, Colors.orange),
    HabitIcon(Icons.book, Colors.deepPurple),
    HabitIcon(Icons.self_improvement, Colors.teal),
    HabitIcon(Icons.run_circle, Colors.red),
    HabitIcon(Icons.restaurant, Colors.green),
    HabitIcon(Icons.local_fire_department, Colors.deepOrange),
    HabitIcon(Icons.savings, Colors.amber),
    HabitIcon(Icons.school, Colors.indigo),
    HabitIcon(Icons.work, Colors.brown),
    HabitIcon(Icons.code, Colors.blueGrey),
    HabitIcon(Icons.music_note, Colors.pink),
    HabitIcon(Icons.sports_soccer, Colors.green),
    HabitIcon(Icons.bed, Colors.deepPurple),
    HabitIcon(Icons.favorite, Colors.red),
    HabitIcon(Icons.star, Colors.amber),
    HabitIcon(Icons.lightbulb, Colors.yellow),
    HabitIcon(Icons.psychology, Colors.purple),
    HabitIcon(Icons.spa, Colors.green),
    HabitIcon(Icons.local_drink, Colors.cyan),
    HabitIcon(Icons.directions_walk, Colors.orange),
    HabitIcon(Icons.monitor_heart, Colors.red),
    HabitIcon(Icons.fastfood, Colors.deepOrange),
    HabitIcon(Icons.laptop, Colors.blueGrey),
    HabitIcon(Icons.timer, Colors.indigo),
    HabitIcon(Icons.pets, Colors.brown),
    HabitIcon(Icons.language, Colors.blue),
    HabitIcon(Icons.travel_explore, Colors.teal),
    HabitIcon(Icons.cleaning_services, Colors.cyan),
    HabitIcon(Icons.check_circle, Colors.green),
  ];

  Future<void> saveHabit() async {
    if (nameController.text.trim().isEmpty) {
      return;
    }

    final box = Hive.box<Habit>('habits');

    await box.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: nameController.text.trim(),
        category: selectedCategory,
        iconCodePoint: selectedIcon.icon.codePoint,
        createdAt: DateTime.now(),
        dailyCounts: {},
        activeDays: selectedDays,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Habit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Habit Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
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
              'Active Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing:2,
              runSpacing: 8,
              children: weekDays.map((day) {
                final label = day.$1;
                final value = day.$2;

                final selected = selectedDays.contains(value);

                return FilterChip(
                  showCheckmark: false,
                  label: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selected,
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey.shade200,
                  side: BorderSide(
                    color: selected ? Colors.green : Colors.grey.shade400,
                  ),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        if (selectedDays.length > 1) {
                          selectedDays.remove(value);
                        }
                      } else {
                        selectedDays.add(value);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              'Choose Icon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final iconItem = icons[index];

                final selected =
                    iconItem.icon.codePoint == selectedIcon.icon.codePoint;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIcon = iconItem;
                    });
                  },
                  child: Card(
                    elevation: selected ? 4 : 1,
                    color: selected ? Colors.lightGreenAccent : null,
                    child: Icon(iconItem.icon, color: iconItem.color, size: 30),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: saveHabit,
                child: const Text(
                  'Create Habit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

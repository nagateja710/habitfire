import 'package:flutter/material.dart';

final Map<int, Color> iconColorMap = {
  Icons.water_drop.codePoint: Colors.blue,
  Icons.fitness_center.codePoint: Colors.blueGrey,
  Icons.book.codePoint: Colors.indigo,
  Icons.self_improvement.codePoint: Colors.teal,
  Icons.run_circle.codePoint: Colors.orange,
  Icons.restaurant.codePoint: Colors.green,
  Icons.local_fire_department.codePoint: Colors.deepOrange,
  Icons.savings.codePoint: Colors.pink,
  Icons.school.codePoint: Colors.purple,
  Icons.work.codePoint: Colors.brown,
  Icons.code.codePoint: Colors.cyan,
  Icons.music_note.codePoint: Colors.deepPurple,
  Icons.sports_soccer.codePoint: Colors.lightGreen,
  Icons.bed.codePoint: Colors.indigoAccent,
  Icons.favorite.codePoint: Colors.red,
  Icons.star.codePoint: Colors.amber,
  Icons.lightbulb.codePoint: Colors.yellow,
  Icons.psychology.codePoint: Colors.purpleAccent,
  Icons.spa.codePoint: Colors.tealAccent,
  Icons.local_drink.codePoint: Colors.lightBlue,
  Icons.directions_walk.codePoint: Colors.lime,
  Icons.monitor_heart.codePoint: Colors.redAccent,
  Icons.fastfood.codePoint: Colors.orangeAccent,
  Icons.laptop.codePoint: Colors.grey,
  Icons.timer.codePoint: Colors.red,
  Icons.pets.codePoint: Colors.brown,
  Icons.language.codePoint: Colors.cyanAccent,
  Icons.travel_explore.codePoint: Colors.teal,
  Icons.cleaning_services.codePoint: Colors.blueAccent,
  Icons.check_circle.codePoint: Colors.green,
};

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int count;
  final int streak;
  final bool completed;
  final VoidCallback onCountTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.count,
    required this.streak,
    required this.completed,
    required this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(
                      iconCodePoint,
                      fontFamily: 'MaterialIcons',
                    ),
                    color:
                        iconColorMap[iconCodePoint] ??
                        Colors.grey,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: onCountTap,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: count > 0
                        ? Colors.green.withOpacity(.15)
                        : Colors.grey.withOpacity(.15),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: count > 0
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (streak > 0)
          Positioned(
            top: 6,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 15,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$streak',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
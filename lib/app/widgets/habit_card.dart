import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int count;
  final bool completed;
  final VoidCallback onCountTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.count,
    required this.completed,
    required this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                color: completed
                    ? Colors.green
                    : Colors.grey,
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
                backgroundColor:
                    count > 0
                        ? Colors.green.withOpacity(.15)
                        : Colors.grey.withOpacity(.15),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        count > 0
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
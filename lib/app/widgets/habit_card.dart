import 'package:flutter/material.dart';
import 'package:habitfire/app/utils/iconcolors.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int count;
  final int streak;
  final bool completed;
  final VoidCallback onCountTap;
  final VoidCallback
  onCountLongPress; // 1. Added the long press callback parameter

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.count,
    required this.streak,
    required this.completed,
    required this.onCountTap,
    required this.onCountLongPress, // 2. Added to the constructor requirements
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
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color:
                          iconColorMap[iconCodePoint]?.withOpacity(0.4) ??
                          Colors.grey.shade300.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        iconColorMap[iconCodePoint]?.withOpacity(0.12) ??
                        Colors.grey.shade300.withOpacity(0.12),
                  ),
                  child: Icon(
                    IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: iconColorMap[iconCodePoint] ?? Colors.grey,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: onCountTap,
                  onLongPress:
                      onCountLongPress, // 3. Bound the long press event handler here
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
                        color: count > 0 ? Colors.green : Colors.grey,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

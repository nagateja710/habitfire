import 'package:hive/hive.dart';

part 'habit.g.dart';
@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  int iconCodePoint;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  Map<String, int> dailyCounts;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.iconCodePoint,
    required this.createdAt,
    this.dailyCounts = const {},
  });
}
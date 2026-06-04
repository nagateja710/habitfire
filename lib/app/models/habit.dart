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

  @HiveField(6)
  List<int> activeDays;

  @HiveField(7)
  bool? isAchieved;

  @HiveField(8)
  DateTime? achievedAt;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.iconCodePoint,
    required this.createdAt,
    this.dailyCounts = const {},
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
    this.isAchieved = false,
    this.achievedAt,
  });
}
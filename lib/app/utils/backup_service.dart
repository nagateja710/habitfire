import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/habit.dart';

class BackupService {
  /// EXPORT BACKUP
  static Future<String> exportJson() async {
    try {
      final box = Hive.box<Habit>('habits');

      final habits = box.values.map((h) {
        return {
          "id": h.id,
          "title": h.title,
          "category": h.category,
          "iconCodePoint": h.iconCodePoint,
          "createdAt": h.createdAt.toIso8601String(),
          "activeDays": h.activeDays,
          "dailyCounts": h.dailyCounts,
        };
      }).toList();

      final backup = {
        "version": 1,
        "exportedAt": DateTime.now().toIso8601String(),
        "habits": habits,
      };

      final dir = await getTemporaryDirectory();

      final file = File(
        '${dir.path}/habitfire_backup.json',
      );

      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(backup),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'HabitFire Backup',
      );

      return 'Backup exported successfully';
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  /// IMPORT BACKUP
  static Future<String> importJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return 'Import cancelled';
      }

      final path = result.files.single.path;

      if (path == null) {
        return 'Invalid file selected';
      }

      final file = File(path);

      final jsonData = jsonDecode(
        await file.readAsString(),
      );

      if (jsonData["habits"] == null) {
        return 'Invalid HabitFire backup';
      }

      final habits =
          List<Map<String, dynamic>>.from(
        jsonData["habits"],
      );

      final box = Hive.box<Habit>('habits');

      await box.clear();

      for (final item in habits) {
        await box.add(
          Habit(
            id: item["id"],
            title: item["title"],
            category: item["category"],
            iconCodePoint:
                item["iconCodePoint"],
            createdAt: DateTime.parse(
              item["createdAt"],
            ),
            activeDays: List<int>.from(
              item["activeDays"] ?? [],
            ),
            dailyCounts:
                Map<String, int>.from(
                  item["dailyCounts"] ?? {},
                ),
          ),
        );
      }

      return 'Backup restored successfully';
    } catch (e) {
      return 'Import failed: $e';
    }
  }
}
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  String priority;

  Reminder({
    required this.title,
    required this.description,
    required this.dateTime,
    this.priority = 'Orta',
  });
}

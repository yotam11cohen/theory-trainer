import 'package:hive/hive.dart';

part 'progress_event.g.dart';

@HiveType(typeId: 3)
class ProgressEvent extends HiveObject {
  @HiveField(0)
  final String lessonId;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final DateTime earnedAt;

  ProgressEvent({
    required this.lessonId,
    required this.score,
    required this.earnedAt,
  });
}

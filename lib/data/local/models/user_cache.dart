import 'package:hive/hive.dart';

part 'user_cache.g.dart';

@HiveType(typeId: 2)
class UserCache extends HiveObject {
  @HiveField(0)
  int totalXp;

  @HiveField(1)
  int level;

  @HiveField(2)
  int streakCount;

  @HiveField(3)
  String? lastActive;

  UserCache({
    required this.totalXp,
    required this.level,
    required this.streakCount,
    this.lastActive,
  });
}

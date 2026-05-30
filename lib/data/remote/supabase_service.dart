import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/driving_lesson.dart';
import '../../domain/models/driving_exercise.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/xp.dart';
import '../../constants.dart';
import '../local/hive_service.dart';
import '../local/models/progress_event.dart';
import '../local/models/user_cache.dart';

class SupabaseService {
  final SupabaseClient _client;
  SupabaseService(this._client);

  Future<String> _carVehicleId() async {
    final res = await _client
        .from('driving_vehicles')
        .select('id')
        .eq('slug', AppConstants.carVehicleSlug)
        .single();
    return res['id'] as String;
  }

  Future<List<DrivingLesson>> fetchLessons() async {
    final vehicleId = await _carVehicleId();
    final data = await _client
        .from('driving_lessons')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('order_index');
    return (data as List).map((e) => DrivingLesson.fromJson(e)).toList();
  }

  Future<List<DrivingExercise>> fetchExercisesForLesson(String lessonId) async {
    final data = await _client
        .from('driving_exercises')
        .select()
        .eq('lesson_id', lessonId)
        .order('order_index');
    return (data as List).map((e) => DrivingExercise.fromJson(e)).toList();
  }

  Future<List<DrivingExercise>> fetchExamPool() async {
    final vehicleId = await _carVehicleId();
    final lessons = await _client
        .from('driving_lessons')
        .select('id')
        .eq('vehicle_id', vehicleId);
    final lessonIds = (lessons as List).map((e) => e['id'] as String).toList();

    final data = await _client
        .from('driving_exercises')
        .select()
        .inFilter('lesson_id', lessonIds)
        .eq('is_exam_question', true);
    return (data as List).map((e) => DrivingExercise.fromJson(e)).toList();
  }

  Future<UserProfile> fetchUserProfile(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  Future<List<Achievement>> fetchAchievements(String userId) async {
    final all = await _client.from('achievements').select();
    final earned = await _client
        .from('user_achievements')
        .select('achievement_id, earned_at')
        .eq('user_id', userId);

    final earnedMap = {
      for (final e in earned as List)
        e['achievement_id'] as String: e['earned_at'] as String
    };

    return (all as List).map((a) {
      final json = Map<String, dynamic>.from(a);
      if (earnedMap.containsKey(json['id'])) {
        json['earned_at'] = earnedMap[json['id']];
      }
      return Achievement.fromJson(json);
    }).toList();
  }

  Future<Set<String>> fetchCompletedLessonIds(String userId) async {
    final data = await _client
        .from('driving_progress')
        .select('lesson_id')
        .eq('user_id', userId);
    return {for (final e in data as List) e['lesson_id'] as String};
  }

  Future<void> recordProgress({
    required String userId,
    required String lessonId,
    required int score,
  }) async {
    final now = DateTime.now();
    final xpEarned = XpCalculator.xpForScore(score);

    await _client.from('driving_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'score': score,
      'completed_at': now.toIso8601String(),
    });

    final profile = await fetchUserProfile(userId);
    final newXp = profile.totalXp + xpEarned;
    final newLevel = XpCalculator.levelFor(newXp);
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = profile.lastActive;
    final lastDay = lastActive != null
        ? DateTime(lastActive.year, lastActive.month, lastActive.day)
        : null;
    final newStreak = lastDay == null
        ? 1
        : lastDay == today
            ? profile.streakCount
            : lastDay == today.subtract(const Duration(days: 1))
                ? profile.streakCount + 1
                : 1;

    await _client.from('users').update({
      'total_xp': newXp,
      'level': newLevel,
      'streak_count': newStreak,
      'last_active': today.toIso8601String(),
    }).eq('id', userId);

    await HiveService.cacheUser(UserCache(
      totalXp: newXp,
      level: newLevel,
      streakCount: newStreak,
      lastActive: today.toIso8601String(),
    ));
    await HiveService.markLessonComplete(lessonId);
  }

  Future<void> flushProgressQueue(String userId) async {
    final queue = await HiveService.getPendingProgress();
    if (queue.isEmpty) return;
    final failed = <ProgressEvent>[];
    for (final event in queue) {
      try {
        await recordProgress(
          userId: userId,
          lessonId: event.lessonId,
          score: event.score,
        );
      } catch (_) {
        failed.add(event);
      }
    }
    await HiveService.clearProgressQueue();
    for (final event in failed) {
      await HiveService.enqueueProgress(event);
    }
  }

  Future<void> updateNotificationPreference(
      String userId, bool enabled) async {
    await _client
        .from('users')
        .update({'notifications_enabled': enabled}).eq('id', userId);
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final data = await _client
        .from('users')
        .select('id, display_name, total_xp')
        .order('total_xp', ascending: false)
        .limit(50);
    return (data as List)
        .asMap()
        .entries
        .map((e) => LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              rank: e.key + 1,
            ))
        .toList();
  }

  Future<int> fetchUserRank(String userId, int userXp) async {
    final data = await _client
        .from('users')
        .select('id')
        .gt('total_xp', userXp);
    return (data as List).length + 1;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

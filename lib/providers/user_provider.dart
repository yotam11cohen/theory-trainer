import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/achievement.dart';
import 'supabase_provider.dart';
import 'auth_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.keepAlive(); // stay alive across tab navigations; invalidate explicitly after progress
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(supabaseServiceProvider).fetchUserProfile(user.id);
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(supabaseServiceProvider).fetchAchievements(user.id);
});

final completedLessonsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(supabaseServiceProvider).fetchCompletedLessonIds(user.id);
});

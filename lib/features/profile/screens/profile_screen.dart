import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart' show supabaseServiceProvider;
import '../../../domain/xp.dart';
import '../widgets/achievement_badge.dart';
import '../../../data/local/hive_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load profile'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child:
                      profile.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Level ${profile.level} • ${profile.totalXp} XP'),
                ]),
              ]),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: XpCalculator.progressToNext(profile.totalXp, profile.level),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Study Reminders'),
                  Switch(
                    value: profile.notificationsEnabled,
                    onChanged: (val) async {
                      final user = ref.read(currentUserProvider);
                      if (user == null) return;
                      try {
                        await ref
                            .read(supabaseServiceProvider)
                            .updateNotificationPreference(user.id, val);
                        ref.invalidate(userProfileProvider);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update notification preference')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: const Text('Show Tutorial'),
                onTap: () async {
                  await HiveService.resetOnboarding();
                  if (context.mounted) context.go('/app/home');
                },
              ),
              const SizedBox(height: 16),
              Text('Achievements',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              achievementsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const SizedBox(),
                data: (achievements) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: achievements
                      .map((a) => AchievementBadge(achievement: a))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

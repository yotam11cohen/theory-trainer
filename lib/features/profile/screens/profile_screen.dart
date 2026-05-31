import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/supabase_provider.dart' show supabaseServiceProvider;
import '../../../domain/xp.dart';
import '../widgets/achievement_badge.dart';
import '../../../data/local/hive_service.dart';
import '../../../shared/onboarding_notifier.dart';

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
                  GestureDetector(
                    onTap: () => _editDisplayName(context, ref, profile.displayName),
                    child: Row(
                      children: [
                        Text(profile.displayName,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 16),
                      ],
                    ),
                  ),
                  Text('Level ${profile.level} • ${profile.totalXp} XP'),
                  const SizedBox(height: 2),
                  Text(
                    '${XpCalculator.levelTitle(profile.level)} · ${XpCalculator.levelDescription(profile.level)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Language / שפה'),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'he', label: Text('עברית')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {ref.watch(localeProvider).languageCode},
                    onSelectionChanged: (s) =>
                        ref.read(localeProvider.notifier).setLocale(Locale(s.first)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: const Text('Show Tutorial'),
                onTap: () async {
                  await HiveService.resetOnboarding();
                  showOnboardingNotifier.value = true;
                  if (context.mounted) context.go('/app/home');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Account',
                    style: TextStyle(color: Colors.red)),
                onTap: () => _confirmDeleteAccount(context, ref),
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

  Future<void> _editDisplayName(
      BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (newName == null || newName.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref
          .read(supabaseServiceProvider)
          .updateDisplayName(user.id, newName);
      ref.invalidate(userProfileProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update name')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all your progress. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(supabaseServiceProvider).deleteAccount(user.id);
      if (context.mounted) context.go('/login');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account')),
        );
      }
    }
  }
}

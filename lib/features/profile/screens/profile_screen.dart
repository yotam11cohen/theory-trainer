import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle),
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
                  Text(l.couldNotLoadProfile),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    child: Text(l.retry),
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
                  Text(l.notificationsLabel),
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
                            SnackBar(content: Text(l.failedUpdateNotification)),
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
                  Text(l.languageLabel),
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
                title: Text(l.showTutorial),
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
                title: Text(l.deleteAccount,
                    style: const TextStyle(color: Colors.red)),
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
              const SizedBox(height: 16),
              Text(l.achievementsTitle,
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
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.displayName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l.save)),
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
        final l2 = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l2.failedUpdateName)),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAccountConfirmTitle),
        content: Text(l.deleteAccountConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete,
                  style: const TextStyle(color: Colors.red))),
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
        final l2 = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l2.failedDeleteAccount)),
        );
      }
    }
  }
}

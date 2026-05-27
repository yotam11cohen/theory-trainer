import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'constants.dart';
import 'app.dart';
import 'data/local/hive_service.dart';
import 'shared/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(AppConstants.supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via --dart-define');
  assert(AppConstants.supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be set via --dart-define');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await HiveService.init();

  tz.initializeTimeZones();
  await NotificationScheduler.init();

  runApp(const ProviderScope(child: ClearedApp()));
}

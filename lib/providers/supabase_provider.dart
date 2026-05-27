import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/remote/supabase_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final supabaseServiceProvider = Provider<SupabaseService>(
  (ref) => SupabaseService(ref.watch(supabaseClientProvider)),
);

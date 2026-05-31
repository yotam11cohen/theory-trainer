import 'package:flutter/foundation.dart';

/// Signals BottomNavShell to re-show the onboarding overlay.
/// Set to true to trigger; BottomNavShell resets it to false after handling.
final showOnboardingNotifier = ValueNotifier<bool>(false);

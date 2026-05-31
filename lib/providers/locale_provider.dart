import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/hive_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(HiveService.getSavedLocale());

  Future<void> setLocale(Locale locale) async {
    await HiveService.saveLocale(locale.languageCode);
    state = locale;
  }
}

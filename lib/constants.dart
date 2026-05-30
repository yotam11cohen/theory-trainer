import 'package:flutter/material.dart';

class AppCategory {
  final String slug;
  final String nameHe;
  final String nameEn;
  final double examWeight;
  final IconData icon;

  const AppCategory({
    required this.slug,
    required this.nameHe,
    required this.nameEn,
    required this.examWeight,
    required this.icon,
  });
}

abstract class AppConstants {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const carVehicleSlug = 'car';

  static const examQuestionCount = 30;
  static const examPassThreshold = 26;

  static const categories = [
    AppCategory(slug: 'signs', nameHe: 'תמרורים ואותות', nameEn: 'Signs & Signals', examWeight: 0.35, icon: Icons.traffic),
    AppCategory(slug: 'safe_driving', nameHe: 'נהיגה בטוחה', nameEn: 'Safe Driving', examWeight: 0.25, icon: Icons.shield_outlined),
    AppCategory(slug: 'laws', nameHe: 'חוקים ותקנות', nameEn: 'Laws & Regulations', examWeight: 0.20, icon: Icons.gavel_outlined),
    AppCategory(slug: 'mechanics', nameHe: 'מכאניקה ורכב', nameEn: 'Mechanics', examWeight: 0.10, icon: Icons.build_outlined),
    AppCategory(slug: 'first_aid', nameHe: 'עזרה ראשונה', nameEn: 'First Aid', examWeight: 0.10, icon: Icons.local_hospital_outlined),
  ];

  static Map<String, double> get categoryWeights =>
      {for (final c in categories) c.slug: c.examWeight};
}

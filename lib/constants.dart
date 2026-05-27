abstract class AppConstants {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const carVehicleSlug = 'car';

  static const xpThresholds = [0, 500, 1500, 3000, 6000];
  static const xpStandard = 10;
  static const xpPerfect = 15;

  static const examQuestionCount = 30;
  static const examPassThreshold = 26;

  static const categoryWeights = {
    'signs': 0.35,
    'safe_driving': 0.25,
    'laws': 0.20,
    'mechanics': 0.10,
    'first_aid': 0.10,
  };
}

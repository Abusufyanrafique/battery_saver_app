import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPref {
  static const key = "seenOnboarding";

  static Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  static Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
}
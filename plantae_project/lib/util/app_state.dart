import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static const String _firstLaunchKey = 'is_first_launch';
  
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    
    if (isFirstLaunch) {
      // Set first launch to false for next time
      await prefs.setBool(_firstLaunchKey, false);
    }
    
    return isFirstLaunch;
  }
  
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  static Future<void> saveUserPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getUserPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clearUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 
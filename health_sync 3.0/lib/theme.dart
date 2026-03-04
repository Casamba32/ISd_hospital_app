import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  // A ValueNotifier acts like a "radio station" broadcasting the theme status
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  // Save the setting to the phone's storage
  static Future<void> toggleTheme(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Load the setting when the app starts
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

// --- TRANSLATION DICTIONARY ---
class AppTexts {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'account_settings': 'Account Settings',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'language': 'App Language',
      'on': 'On',
      'off': 'Off',
    },
    'es': {
      'settings': 'Ajustes',
      'dark_mode': 'Modo Oscuro',
      'account_settings': 'Cuenta',
      'help_support': 'Ayuda y Soporte',
      'logout': 'Cerrar Sesión',
      'language': 'Idioma del App',
      'on': 'Activo',
      'off': 'Inactivo',
    },
    'fr': {
      'settings': 'Paramètres',
      'dark_mode': 'Mode Sombre',
      'account_settings': 'Compte',
      'help_support': 'Aide et Support',
      'logout': 'Déconnexion',
      'language': 'Langue',
      'on': 'Allumé',
      'off': 'Éteint',
    },
    'de': {
      'settings': 'Einstellungen',
      'dark_mode': 'Dunkelmodus',
      'account_settings': 'Kontoeinstellungen',
      'help_support': 'Hilfe & Support',
      'logout': 'Abmelden',
      'language': 'Sprache',
      'on': 'An',
      'off': 'Aus',
    },
  };

  static String tr(String key) {
    String code = LanguageManager.localeNotifier.value;
    return _localizedValues[code]?[key] ?? _localizedValues['en']![key]!;
  }
}

// --- LANGUAGE MANAGER ---
class LanguageManager {
  static const Map<String, String> languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  static final ValueNotifier<String> localeNotifier = ValueNotifier<String>('en');

  static Future<void> updateLanguage(String? newLang) async {
    if (newLang != null && languages.containsKey(newLang)) {
      localeNotifier.value = newLang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', newLang);
    }
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    localeNotifier.value = prefs.getString('selectedLanguage') ?? 'en';
  }
}

// --- THEME MANAGER ---
class ThemeManager {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  static Future<void> toggleTheme(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.loadTheme();
  await LanguageManager.loadLanguage();

  await Supabase.initialize(
    url: 'https://iphvfncwiltvrqepinle.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwaHZmbmN3aWx0dnJxZXBpbmxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMzU3NjcsImV4cCI6MjA4NzkxMTc2N30.hPDlUPcfFpKMRiarJtb543GSmamM175EOrn0LVUJNvc', // Replace with your key
  );

  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageManager.localeNotifier,
          builder: (context, langCode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: currentMode,
              theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
              darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.blue),
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                // Add your other routes here...
              },
            );
          },
        );
      },
    );
  }
}
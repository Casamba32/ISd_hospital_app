import 'package:flutter/material.dart';
import 'package:hospital_app/chatbot/chatbot.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this to pubspec.yaml
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/records_screen.dart';
import 'screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- THEME MANAGER CLASS ---
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
  
  // Load the saved theme preference from disk
  await ThemeManager.loadTheme();

  await Supabase.initialize(
    url: 'https://iphvfncwiltvrqepinle.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwaHZmbmN3aWx0dnJxZXBpbmxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMzU3NjcsImV4cCI6MjA4NzkxMTc2N30.hPDlUPcfFpKMRiarJtb543GSmamM175EOrn0LVUJNvc',
  );

  print("Supabase Connected: ${Supabase.instance.client.rest.url}");
  
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder listens for theme changes globally
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hospital Management System',
          // Theme Configuration
          themeMode: currentMode, 
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          // Routes (Unchanged)
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/admin': (context) => const AdminDashboardScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/account-settings': (context) => const AccountSettingsScreen(),
            '/bills': (context) => const BillsScreen(),
            '/records': (context) => const RecordsScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/chatbot': (context) => const AIChatbotPage(),
            
          },
        );
      },
    );
  }
}
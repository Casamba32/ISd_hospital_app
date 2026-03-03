import 'package:flutter/material.dart';
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

// 1. Changed main to be async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iphvfncwiltvrqepinle.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwaHZmbmN3aWx0dnJxZXBpbmxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMzU3NjcsImV4cCI6MjA4NzkxMTc2N30.hPDlUPcfFpKMRiarJtb543GSmamM175EOrn0LVUJNvc',
  );

  // Use 'Supabase.instance.client' instead of just 'supabase'
  // This checks the internal Supabase configuration
 print("Supabase Connected: ${Supabase.instance.client.rest.url}");
  
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management System',
      theme: ThemeData(
        primaryColor: Colors.blue, // Corrected from primarySwatch for Material 3 compatibility
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
        // '/profile': (context) => const ProfileScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
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

void main() {
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

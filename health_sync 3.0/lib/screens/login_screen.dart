import 'package:flutter/material.dart';
import '../services/in_memory_db.dart';
import '../models/models.dart';
import 'patient/patient_dashboard.dart';
import 'admin/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  String _msg = '';

  void _login() {
    final email = _emailCtl.text.trim();
    if (email.isEmpty) {
      setState(() => _msg = 'Enter email');
      return;
    }

    final user = InMemoryDB.findUserByEmail(email);
    if (user == null) {
      setState(() => _msg = 'User not found');
      return;
    }

    // Navigate based on role
    if (user.role == 'patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientDashboard(user: user)),
      );
    } else if (user.role == 'staff' || user.role == 'doctor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hospital Management System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('Create new account'),
            ),
            const SizedBox(height: 12),
            if (_msg.isNotEmpty)
              Text(_msg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            const Text(
              'Test accounts:\npatient@test.com (Patient)\ndoctor@test.com (Doctor)\nadmin@test.com (Staff)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

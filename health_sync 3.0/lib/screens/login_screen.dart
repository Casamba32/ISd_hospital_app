import 'package:flutter/material.dart';
import '../services/in_memory_db.dart';
import '../models/models.dart';
import 'patient/patient_dashboard.dart';
import 'admin/admin_dashboard_screen.dart';
import 'register_screen.dart';
import 'dart:convert'; // For turning data into JSON
import 'package:http/http.dart' as http; // For sending the message

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String _msg = '';

  void _login() async { // ✅ 'await' will work now!
    final email = _emailCtl.text.trim();
  final password = _passwordCtl.text.trim(); // NEW: Read the password here

  if (email.isEmpty || password.isEmpty) {
    setState(() => _msg = 'Enter email and password');
    return;
  }

   // 1. Where is Strapi? 
  // If using Android Emulator, use 10.0.2.2. If on Web, use localhost.
  const String url = "http://localhost:1337/api/auth/local";

  try {
    // 2. Send the "Login Request"
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": email, // Strapi calls the email "identifier"
        "password": password,
      }),
    );

    // 3. What did Strapi say back?
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Strapi sends back a 'jwt' (The Key) and 'user' (The Info)
      final userFromStrapi = data['user']; 

      // 4. Navigate based on role (Make sure your Strapi user has a 'role' field!)
      // For now, let's keep your navigation logic
      if (userFromStrapi['email'].contains('patient')) {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => PatientDashboard(user: userFromStrapi)),
         );
      } else {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
         );
      }
    } else {
      // If Strapi says "No" (400 error)
      setState(() => _msg = 'Invalid email or password');
    }
  } catch (e) {
    // If the server is off or the IP is wrong
    setState(() => _msg = 'Cannot connect to server');
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
            TextField(
              controller: _passwordCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
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

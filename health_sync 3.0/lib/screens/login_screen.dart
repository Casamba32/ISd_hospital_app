import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; 
import '../models/models.dart'; 
import 'patient/patient_dashboard.dart';
import 'admin/admin_dashboard_screen.dart';
import 'register_screen.dart';
import 'doctor/doctor_dashboard_screen.dart'; // Ensure this path is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String _msg = '';
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _msg = 'Enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _msg = '';
    });

    try {
      // 1. Sign in using Supabase Auth
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;

      if (user != null) {
        // 2. Extract metadata and determine role
        final metadata = user.userMetadata ?? {};
        final String role = metadata['role'] ?? 'patient';
        final String name = metadata['name'] ?? 'User';

        // 3. Create our local User model
        final currentUser = User(
          id: user.id,
          name: name,
          email: user.email!,
          role: role,
        );

        if (!mounted) return;

        // 4. Role-based Navigation
        if (role == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboardScreen(user: currentUser),
            ),
          );
        } else if (role == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDashboard(user: currentUser),
            ),
          );
        } else {
          // Default to Admin or generic route
          Navigator.pushReplacementNamed(context, '/admin');
        }
      }
    } on AuthException catch (error) {
      setState(() => _msg = error.message);
    } catch (e) {
      setState(() => _msg = 'Unexpected error occurred');
      debugPrint("Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Hospital Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailCtl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Create new account'),
                ),
                if (_msg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _msg,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; 
import '../models/models.dart'; 
import 'patient/patient_dashboard.dart';
import 'admin/admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'doctor/doctor_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  
  const RegisterScreen({Key? key}) : super(key: key);


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  // 1. Added Confirm Password Controller
  final _confirmPasswordCtl = TextEditingController();
  
  String? _role; 
  String _msg = '';
  bool _isLoading = false;

  Future<void> _register() async {
    final name = _nameCtl.text.trim();
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text.trim();
    final confirmPassword = _confirmPasswordCtl.text.trim();

    // 2. Validation Checks
    if (name.isEmpty || email.isEmpty || password.isEmpty || _role == null) {
      setState(() => _msg = 'Please fill all fields and select a role');
      return;
    }

    // 3. Match Logic
    if (password != confirmPassword) {
      setState(() => _msg = 'Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setState(() => _msg = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _msg = '';
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': _role,
        },
      );

      final user = res.user;

      if (user != null) {
        if (_role == 'doctor') {
          try {
            await Supabase.instance.client.from('doctors').insert({
              'id': user.id,
              'name': name,
              'email': email,
            });
          } catch (dbError) {
            debugPrint("DB Error: $dbError");
            setState(() => _msg = "Auth success, but profile creation failed.");
            setState(() => _isLoading = false);
            return; 
          }
        }

        final currentUser = User(
          id: user.id,
          name: name,
          email: email,
          role: _role!,
        );

        if (!mounted) return;

       // inside register_screen.dart -> _register()

if (_role == 'patient') {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => PatientDashboard(user: currentUser)),
    (route) => false,
  );
} else if (_role == 'doctor') {
  // NEW: Navigate specifically to Doctor Dashboard
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => DoctorDashboardScreen(user: currentUser)),
    (route) => false,
  );
} else {
  // Staff or Admin
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    (route) => false,
  );
}
      }
    } on AuthException catch (error) {
      setState(() => _msg = error.message);
    } catch (e) {
      setState(() => _msg = 'Unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Create New Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            // 4. Added Confirm Password UI Field
            TextField(
              controller: _confirmPasswordCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Select Role:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
                  hint: const Text("Choose a role..."),
                  items: ['patient', 'doctor', 'staff']
                      .map((r) => DropdownMenuItem(
                            value: r, 
                            child: Text(r.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _register, 
                  child: const Text('Register Account', style: TextStyle(fontSize: 16)),
                ),
            const SizedBox(height: 16),
            
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text('Already have an account? Sign In'),
              ),
            if (_msg.isNotEmpty) 
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade50,
                child: Text(
                  _msg, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
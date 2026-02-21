import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String _role = 'patient';
  String _msg = '';
  bool _isLoading = false; // Added to show user we are working

  Future<void> _register() async {
    final name = _nameCtl.text.trim();
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _msg = 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _msg = '';
    });

    // Since you are on Chrome Web, we use localhost
    const String url = "http://localhost:1337/api/auth/local/register";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,    // Strapi needs a 'username'
          "email": email,
          "password": password,
          // "role": _role,       // Note: Strapi usually needs extra config to accept custom roles via API
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _msg = 'Account created successfully!');
        // Optional: Go back to login after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() => _msg = 'Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      setState(() => _msg = 'Cannot connect to server. Check if Strapi is running.');
    } finally {
      setState(() => _isLoading = false);
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
              decoration: const InputDecoration(labelText: 'Username (No spaces)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtl,
              obscureText: true, // Hide password dots
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 8),
            const Text("Select Role:", style: TextStyle(color: Colors.grey)),
            DropdownButton<String>(
              value: _role,
              isExpanded: true,
              items: ['patient', 'doctor', 'staff']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 16),
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ElevatedButton(onPressed: _register, child: const Text('Register')),
            const SizedBox(height: 12),
            if (_msg.isNotEmpty) 
              Text(
                _msg, 
                style: TextStyle(color: _msg.contains('Success') ? Colors.green : Colors.red)
              ),
          ],
        ),
      ),
    );
  }
}
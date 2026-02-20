import 'package:flutter/material.dart';
import '../services/in_memory_db.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  String _role = 'patient';
  String _msg = '';

  void _register() {
    final name = _nameCtl.text.trim();
    final email = _emailCtl.text.trim();
    if (name.isEmpty || email.isEmpty) {
      setState(() => _msg = 'Enter name and email');
      return;
    }
    InMemoryDB.createUser(name, email, _role);
    setState(() => _msg = 'Account created successfully');
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
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _role,
              items: ['patient', 'doctor', 'staff']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
            const SizedBox(height: 12),
            if (_msg.isNotEmpty) Text(_msg, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

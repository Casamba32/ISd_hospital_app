import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../widgets/bottom_nav_bar.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _twoFactorEnabled = false;
  bool _prefAppointments = true;
  bool _prefBilling = false;
  bool _prefPharmacy = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _openChangePasswordDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPassword = _passwordController.text;
              Navigator.of(ctx).pop();
              BackendService.changePassword(newPassword).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              });
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              BackendService.logOut().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications', arguments: 3);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock),
            onTap: _openChangePasswordDialog,
          ),
          SwitchListTile(
            title: const Text('Enable Two-Factor Authentication'),
            value: _twoFactorEnabled,
            onChanged: (bool value) {
              setState(() {
                _twoFactorEnabled = value;
              });
              BackendService.toggleTwoFactor(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Two-factor authentication enabled'
                        : 'Two-factor authentication disabled',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage Notification Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          CheckboxListTile(
            title: const Text('Appointment Reminders'),
            value: _prefAppointments,
            onChanged: (bool? value) {
              setState(() {
                _prefAppointments = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Billing Updates'),
            value: _prefBilling,
            onChanged: (bool? value) {
              setState(() {
                _prefBilling = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Pharmacy Notifications'),
            value: _prefPharmacy,
            onChanged: (bool? value) {
              setState(() {
                _prefPharmacy = value ?? false;
              });
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: _confirmLogout,
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavBar(selectedIndex: 3),
    );
  }
}

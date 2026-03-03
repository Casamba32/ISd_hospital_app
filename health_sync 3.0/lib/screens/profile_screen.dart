import 'package:flutter/material.dart';
import 'package:hospital_app/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide  User; // Add this
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  
  const ProfileScreen({Key? key, required User user}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    // 1. Get the current user from Supabase
    final user = Supabase.instance.client.auth.currentUser;

    // 2. Extract the Name and Email
    // If name isn't found in metadata, we show 'Guest' as a fallback
    final String name = user?.userMetadata?['name'] ?? 'Guest';
    final String email = user?.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name, // Display the real Name from Supabase
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              email, // Display the real Email from Supabase
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/account-settings');
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // 3. Added a Logout Button to test the connection
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavBar(selectedIndex: 3),
    );
  }
}
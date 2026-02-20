import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications', arguments: 0);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Billing'),
              subtitle: const Text('5 pending invoices'),
              onTap: () {
                Navigator.pushNamed(context, '/bills');
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_pharmacy),
              title: const Text('Pharmacy'),
              subtitle: const Text('12 new orders'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pharmacy section tapped')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Reports'),
              subtitle: const Text('Coming soon'),
              enabled: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavBar(selectedIndex: 0),
    );
  }
}

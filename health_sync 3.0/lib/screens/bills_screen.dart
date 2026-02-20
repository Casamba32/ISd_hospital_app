import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoice #1001'),
              subtitle: const Text('Amount: \$250.00 - Paid'),
              trailing: const Chip(
                label: Text('Paid'),
                backgroundColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoice #1002'),
              subtitle: const Text('Amount: \$150.00 - Due 10/30'),
              trailing: const Chip(
                label: Text('Pending'),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoice #1003'),
              subtitle: const Text('Amount: \$75.00 - Due 11/15'),
              trailing: const Chip(
                label: Text('Pending'),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavBar(selectedIndex: 2),
    );
  }
}

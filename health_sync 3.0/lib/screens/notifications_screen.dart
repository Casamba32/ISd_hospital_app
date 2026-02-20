import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int currentIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Appointment Reminder'),
              subtitle: Text('Appointment with Dr. Smith at 10:00 AM tomorrow'),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.payment),
              title: Text('Billing Alert'),
              subtitle: Text('Invoice #1002 payment is due on 10/30'),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_pharmacy),
              title: Text('Pharmacy Update'),
              subtitle: Text('Medication XYZ is ready for pickup'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(selectedIndex: currentIndex),
    );
  }
}

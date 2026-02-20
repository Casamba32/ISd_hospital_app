import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Medical records will appear here',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomNavBar(selectedIndex: 1),
    );
  }
}

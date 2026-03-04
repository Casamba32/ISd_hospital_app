import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/models.dart';
import 'book_appointment.dart';
import 'medical_records.dart';
import '../profile_screen.dart';

class PatientDashboard extends StatefulWidget {
  final User user;
  const PatientDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> _titles = ['Your dashboard', 'My Appointments', 'Profile'];

    final List<Widget> _tabs = [
      BookAppointmentPage(patient: widget.user),
      MedicalRecordsPage(patient: widget.user),
      ProfileScreen(user: widget.user),
    ];

    // Format Name
    String rawName = widget.user.name.split(' ')[0]; 
    String formattedName = rawName.isNotEmpty 
        ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase() 
        : "Guest";

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Text in Black
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Hi $formattedName,",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set to Black
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
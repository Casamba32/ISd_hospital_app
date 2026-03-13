import 'package:flutter/material.dart';
import 'package:hospital_app/chatbot/chatbot.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/models.dart';
import 'book_appointment.dart';
import 'medical_records.dart';

// Ensure this filename matches your chatbot file
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
    // 1. Updated Titles for 4 tabs
    final List<String> _titles = [
      'Your Dashboard', 
      'My Appointments', 
      'Doc AI Assistant', 
      'Profile'
    ];

    // 2. Updated Tabs List (Matches the order of the Navbar items)
    final List<Widget> _tabs = [
      BookAppointmentPage(patient: widget.user),
      MedicalRecordsPage(patient: widget.user),
      const AIChatbotPage(), 
      ProfileScreen(user: widget.user),
    ];

    // Format Name for Greeting
    String rawName = widget.user.name.split(' ')[0]; 
    String formattedName = rawName.isNotEmpty 
        ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase() 
        : "Guest";

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        // Changes title based on the selected tab
        title: Text(_titles[_index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Text: Only shows on the "Book" tab (Index 0)
          if (_index == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                "Hi $formattedName,",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
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
        // Fixed type ensures labels and icons don't "shift" or disappear
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), 
            label: 'Book'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined), 
            label: 'Records'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined), // Modern AI Icon
            label: 'Doc AI'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
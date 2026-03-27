import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/models.dart'; 
import '../profile_screen.dart'; 
import '../patient/medical_records.dart'; 

class DoctorDashboardScreen extends StatefulWidget {
  final User user;
  const DoctorDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _index = 0;

  // --- DATABASE ACTIONS ---
  Future<void> _markAsDone(String id) async {
    try {
      await Supabase.instance.client.from('appointments').update({'status': 'done'}).match({'id': id});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment Done"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await Supabase.instance.client.from('appointments').delete().match({'id': id});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment Deleted")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete Failed: $e"), backgroundColor: Colors.red));
    }
  }

  void _navigateToPatientRecords(Map<String, dynamic> aptData) {
    final patientUser = User(id: aptData['patient_id'], name: aptData['patient_name'] ?? 'Patient', role: 'patient', email: '');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
      appBar: AppBar(title: Text("${patientUser.name}'s History")),
      body: MedicalRecordsPage(patient: patientUser),
    )));
  }

  @override
  Widget build(BuildContext context) {
    // Determine the title based on the active tab
    String title;
    switch (_index) {
      case 0: title = 'Pending Appointments'; break;
      case 1: title = 'History'; break;
      case 2: title = 'Doctor Profile'; break;
      default: title = 'Dashboard';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      // IMPORTANT: ProfileScreen is loaded as the body here, not pushed as a new page.
      body: _index == 2 
          ? const ProfileScreen() 
          : _buildAppointmentList(isRecords: _index == 1),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Pending'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAppointmentList({required bool isRecords}) {
    // create a typed stream reference to silence any editor complaints
    final Stream<List<Map<String, dynamic>>> appointmentStream =
        Supabase.instance.client
            .from('appointments')
            .stream(primaryKey: ['id']);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: appointmentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        List<Map<String, dynamic>> appointments = snapshot.data!.where((apt) {
          final isDoctor = apt['doctor_id'] == widget.user.id;
          final status = (apt['status'] ?? 'pending').toString().toLowerCase();
          return isDoctor && status == (isRecords ? 'done' : 'pending');
        }).toList();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final apt = appointments[index];
                  final aptId = apt['id'].toString();

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () => _deleteAppointment(aptId),
                          leading: const Icon(Icons.person_outline),
                          title: Text(apt['patient_name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Reason: ${apt['reason'] ?? 'Not specified'}"),
                          trailing: !isRecords ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30), 
                                onPressed: () => _markAsDone(aptId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 30), 
                                onPressed: () => _deleteAppointment(aptId),
                              ),
                            ],
                          ) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToPatientRecords(apt),
                              icon: const Icon(Icons.history, size: 16),
                              label: const Text("Medical History"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/models.dart'; 
import '../profile_screen.dart'; 
import '../patient/medical_records.dart';
import '../../main.dart'; 

class DoctorDashboardScreen extends StatefulWidget {
  final User user;
  const DoctorDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _index = 0;
  Map<String, int> _priorityScores = {}; 
  bool _isSorting = false;

  // --- AI TRIAGE LOGIC (LOCKED - AS REQUESTED) ---
  Future<void> _sortByAI(List<Map<String, dynamic>> appointments) async {
    if (appointments.isEmpty) return;
    setState(() => _isSorting = true);
    try {
      final dataForAI = appointments.map((a) => 
        "ID: ${a['id']}, Reason: ${a['reason'] ?? 'Routine'}"
      ).join("\n");

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "google/gemini-2.0-flash-lite-001",
          "messages": [
            {"role": "system", "content": "Return ONLY a simple JSON object where keys are IDs and values are integer scores 1-10."},
            {"role": "user", "content": dataForAI}
          ],
          "response_format": { "type": "json_object" }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String content = responseData['choices'][0]['message']['content'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final decodedContent = jsonDecode(content);
        setState(() {
          if (decodedContent is Map) {
            _priorityScores = decodedContent.map((k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0));
          }
          _isSorting = false;
        });
      }
    } catch (e) {
      setState(() => _isSorting = false);
    }
  }

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
      case 0: title = 'Urgency Triage'; break;
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
          ? ProfileScreen(user: widget.user) 
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

        if (!isRecords && _priorityScores.isNotEmpty) {
          appointments.sort((a, b) {
            int sA = _priorityScores[a['id'].toString()] ?? 0;
            int sB = _priorityScores[b['id'].toString()] ?? 0;
            return sB.compareTo(sA);
          });
        }

        return Column(
          children: [
            if (!isRecords && appointments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: _isSorting ? null : () => _sortByAI(appointments),
                  icon: _isSorting ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bolt),
                  label: Text(_isSorting ? "AI Analyzing..." : "AI Sort by Urgency"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade50, foregroundColor: Colors.orange.shade900),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final apt = appointments[index];
                  final aptId = apt['id'].toString();
                  final score = _priorityScores[aptId];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () => _deleteAppointment(aptId),
                          leading: score != null 
                            ? CircleAvatar(
                                backgroundColor: score >= 7 ? Colors.red : Colors.orange,
                                child: Text("$score", style: const TextStyle(color: Colors.white, fontSize: 12)),
                              )
                            : const Icon(Icons.person_outline),
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
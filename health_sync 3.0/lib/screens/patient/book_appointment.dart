import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/models.dart';

class BookAppointmentPage extends StatefulWidget {
  final User patient;
  const BookAppointmentPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _reasonCtl = TextEditingController();
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorName;
  String? _selectedDoctorId;
  bool _isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final data = await Supabase.instance.client
          .from('doctors')
          .select('id, name')
          .order('name');
      setState(() {
        _doctors = List<Map<String, dynamic>>.from(data);
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() => _isLoadingDoctors = false);
      debugPrint("Error fetching doctors: $e");
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null || _reasonCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor and enter a reason')),
      );
      return;
    }

    try {
      // This insert sends the data to the 'appointments' table
      // It includes doctor_id so the Doctor's Dashboard can filter for it.
      await Supabase.instance.client.from('appointments').insert({
        'patient_id': widget.patient.id,
        'patient_name': widget.patient.name,
        'doctor_id': _selectedDoctorId,
        'doctor_name': _selectedDoctorName,
        'reason': _reasonCtl.text.trim(),
        'appointment_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      if (!mounted) return;
      
      _reasonCtl.clear();
      setState(() {
        _selectedDoctorName = null;
        _selectedDoctorId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment Booked! check your Records.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Book New Appointment',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 24),
        
        // Doctor Selection
        const Text("Choose a Specialist", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _isLoadingDoctors
            ? const LinearProgressIndicator()
            : DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: _doctors.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc['id'].toString(),
                    child: Text("Dr. ${doc['name']}", style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (val) {
                  final doc = _doctors.firstWhere((d) => d['id'] == val);
                  setState(() {
                    _selectedDoctorId = val;
                    _selectedDoctorName = doc['name'];
                  });
                },
              ),
        
        const SizedBox(height: 20),
        
        // Reason Field
        const Text("Reason for Visit", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonCtl,
          maxLines: 3,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Describe your symptoms...',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Button
        ElevatedButton(
          onPressed: _bookAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Confirm Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 30),
        const Divider(),
        const SizedBox(height: 10),
        const Text("Note: Your request will be sent directly to the doctor for approval.", 
          style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
      ],
    );
  }
}
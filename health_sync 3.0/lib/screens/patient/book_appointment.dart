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
  String? _selectedTime; 
  bool _isLoadingDoctors = true;

  // Modern Time Slots
  final List<String> _timeSlots = [
    "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM", 
    "02:00 PM", "03:00 PM", "04:00 PM", "05:00 PM"
  ];

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
    // Validation check
    if (_selectedDoctorId == null || _selectedTime == null || _reasonCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a doctor, time slot, and enter a reason'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Insert into Supabase
      await Supabase.instance.client.from('appointments').insert({
        'patient_id': widget.patient.id,
        'patient_name': widget.patient.name,
        'doctor_id': _selectedDoctorId,
        'doctor_name': _selectedDoctorName,
        'reason': _reasonCtl.text.trim(),
        'appointment_date': DateTime.now().toIso8601String(),
        'appointment_time': _selectedTime, // New time field
        'status': 'pending',
      });

      if (!mounted) return;
      
      // Clear local state
      _reasonCtl.clear();
      setState(() {
        _selectedDoctorName = null;
        _selectedDoctorId = null;
        _selectedTime = null;
      });

      // --- GREEN SUCCESS MESSAGE ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Appointment successfully booked!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
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
                  prefixIcon: Icon(Icons.medical_services_outlined, color: Colors.blue),
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
        
        const SizedBox(height: 24),

        // Time Slot Selection (Innovative UI)
        const Text("Select Preferred Time", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((time) {
            bool isSelected = _selectedTime == time;
            return InkWell(
              onTap: () => setState(() => _selectedTime = time),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade700 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade800 : Colors.blue.shade100,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blue.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        
        // Reason Field
        const Text("Reason for Visit", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonCtl,
          maxLines: 2,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Tell us your symptoms...',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Action Button
        ElevatedButton(
          onPressed: _bookAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 3,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 20),
        const Text(
          "Your request is sent to the doctor for review. Check 'Records' for status updates.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)
        ),
      ],
    );
  }
}
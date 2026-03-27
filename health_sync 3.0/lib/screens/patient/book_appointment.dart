import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:speech_to_text/speech_to_text.dart' as stt; // Add this
import '../../models/models.dart';

class BookAppointmentPage extends StatefulWidget {
  final User patient;
  const BookAppointmentPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _reasonCtl = TextEditingController();
  
  // --- VOICE CONTROL VARIABLES ---
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;

  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorName;
  String? _selectedDoctorId;
  String? _selectedTime; 
  bool _isLoadingDoctors = true;

  final List<String> _timeSlots = [
    "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM", 
    "02:00 PM", "03:00 PM", "04:00 PM", "05:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize speech
    _fetchDoctors();
  }

  // --- VOICE CONTROL LOGIC ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _reasonCtl.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final data = await Supabase.instance.client.from('doctors').select('id, name').order('name');
      setState(() {
        _doctors = List<Map<String, dynamic>>.from(data);
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() => _isLoadingDoctors = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null || _selectedTime == null || _reasonCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Colors.orange),
      );
      return;
    }
    // ... rest of your insertion logic remains the same
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
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.medical_services_outlined, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                items: _doctors.map((doc) => DropdownMenuItem(value: doc['id'].toString(), child: Text("Dr. ${doc['name']}"))).toList(),
                onChanged: (val) {
                  final doc = _doctors.firstWhere((d) => d['id'] == val);
                  setState(() { _selectedDoctorId = val; _selectedDoctorName = doc['name']; });
                },
              ),
        
        const SizedBox(height: 24),

        // Time Slots (Keep your existing UI)
        const Text("Select Preferred Time", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((time) {
            bool isSelected = _selectedTime == time;
            return InkWell(
              onTap: () => setState(() => _selectedTime = time),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade700 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.blue.shade800)),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        
        // --- REASON FIELD WITH VOICE BUTTON ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Reason for Visit", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
            // Microphone Button
            GestureDetector(
              onTap: _listen,
              child: CircleAvatar(
                backgroundColor: _isListening ? Colors.red : Colors.blue.shade700,
                radius: 20,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonCtl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: _isListening ? 'Listening...' : 'Tell us your symptoms...',
            border: const OutlineInputBorder(),
            suffixIcon: _isListening ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : null,
          ),
        ),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: _bookAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}
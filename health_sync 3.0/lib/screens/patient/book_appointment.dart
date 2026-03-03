import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; // Hide conflicting User type
import '../../models/models.dart';

class BookAppointmentPage extends StatefulWidget {
  final User patient;
  const BookAppointmentPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _reasonCtl = TextEditingController();
  
  // Doctor fetching variables
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorName;
  bool _isLoadingDoctors = true;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // Fetch doctors from Supabase
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

  // Logic to save appointment to Supabase
  Future<void> _bookAppointment() async {
    if (_selectedDoctorName == null || _reasonCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor and provide a reason')),
      );
      return;
    }

    // Find the selected doctor's ID from our list
    final selectedDoc = _doctors.firstWhere((doc) => doc['name'] == _selectedDoctorName);
    final String doctorId = selectedDoc['id'];

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      await Supabase.instance.client.from('appointments').insert({
        'patient_id': widget.patient.id,
        'patient_name': widget.patient.name,
        'doctor_id': doctorId,
        'doctor_name': _selectedDoctorName,
        'appointment_date': dateTime.toIso8601String(),
        'reason': _reasonCtl.text,
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );

      _reasonCtl.clear();
      setState(() {
        _selectedDoctorName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Book New Appointment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                const Text("Select Doctor:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                _isLoadingDoctors
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDoctorName,
                            isExpanded: true,
                            hint: const Text("Choose an available doctor"),
                            items: _doctors.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc['name'].toString(),
                                child: Text("Dr. ${doc['name']}"),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedDoctorName = val),
                          ),
                        ),
                      ),
                
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonCtl,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Visit',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
                ListTile(
                  title: Text('Time: ${_selectedTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) setState(() => _selectedTime = time);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _bookAppointment,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Book Appointment'),
                ),
                const Divider(height: 40),
                const Text(
                  'Your Appointment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // --- REAL-TIME APPOINTMENT LIST ---
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: Supabase.instance.client
                      .from('appointments')
                      .stream(primaryKey: ['id'])
                      .eq('patient_id', widget.patient.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No appointments scheduled.');
                    }
                    final appointments = snapshot.data!;
                    return Column(
                      children: appointments.map((apt) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.event_note, color: Colors.blue),
                          title: Text('Dr. ${apt['doctor_name']}'),
                          subtitle: Text(
                            'Date: ${DateTime.parse(apt['appointment_date']).toLocal().toString().substring(0, 16)}\nReason: ${apt['reason']}'
                          ),
                          trailing: Chip(
                            label: Text(apt['status'].toString().toUpperCase()),
                            backgroundColor: apt['status'] == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
                          ),
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
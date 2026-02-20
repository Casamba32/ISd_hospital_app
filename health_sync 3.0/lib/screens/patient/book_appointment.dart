import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/in_memory_db.dart';

class BookAppointmentPage extends StatefulWidget {
  final User patient;
  const BookAppointmentPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _doctorCtl = TextEditingController();
  final _reasonCtl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _bookAppointment() {
    if (_doctorCtl.text.isEmpty || _reasonCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: widget.patient.id,
      doctorName: _doctorCtl.text,
      dateTime: dateTime,
      reason: _reasonCtl.text,
    );

    InMemoryDB.addAppointment(appointment);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment booked successfully')),
    );

    _doctorCtl.clear();
    _reasonCtl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appointments = InMemoryDB.getAppointmentsForPatient(widget.patient.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Book New Appointment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _doctorCtl,
            decoration: const InputDecoration(
              labelText: 'Doctor Name',
              border: OutlineInputBorder(),
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
              if (date != null) {
                setState(() => _selectedDate = date);
              }
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
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _bookAppointment,
            child: const Text('Book Appointment'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Appointments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (appointments.isEmpty)
            const Text('No appointments scheduled')
          else
            ...appointments.map((apt) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Dr. ${apt.doctorName}'),
                    subtitle: Text(
                      '${apt.dateTime.toLocal()}\n${apt.reason}',
                    ),
                    trailing: Chip(label: Text(apt.status)),
                  ),
                )),
        ],
      ),
    );
  }
}

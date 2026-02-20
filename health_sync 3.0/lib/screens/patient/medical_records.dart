import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/in_memory_db.dart';

class MedicalRecordsPage extends StatelessWidget {
  final User patient;
  const MedicalRecordsPage({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final records = InMemoryDB.getMedicalRecordsForPatient(patient.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Medical Records',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No medical records available'),
              ),
            )
          else
            ...records.map((record) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dr. ${record.doctorName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${record.date.toLocal()}'.split(' ')[0],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Diagnosis: ${record.diagnosis}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prescription: ${record.prescription}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

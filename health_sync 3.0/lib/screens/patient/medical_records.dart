import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:http/http.dart' as http;
import '../../models/models.dart';

class MedicalRecordsPage extends StatefulWidget {
  final User patient;
  const MedicalRecordsPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  String? _aiSummary;
  bool _isSummarizing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('appointments')
          .stream(primaryKey: ['id'])
          .eq('patient_id', widget.patient.id)
          .order('appointment_date', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text("${widget.patient.name}'s Records", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),

            // AI SUMMARIZE SECTION
            if (_aiSummary != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.amber.shade200)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 18, color: Colors.amber),
                        SizedBox(width: 8),
                        Text("AI Insight", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiSummary!, style: const TextStyle(color: Colors.black87, height: 1.4)),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _isSummarizing ? null : () => _generateAISummary(records),
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isSummarizing ? "Analyzing History..." : "Summarize with AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700, 
                  foregroundColor: Colors.white,        
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            const SizedBox(height: 24),
            const Text("Recent Visits", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            if (records.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("No records found.", style: TextStyle(color: Colors.grey)),
              )),

            // DISPLAY WHITE APPOINTMENT CARDS
            ...records.map((rec) => Card(
              color: Colors.white, // FORCED WHITE
              surfaceTintColor: Colors.white, // PREVENTS TINTING IN MATERIAL 3
              elevation: 3, // ADDS SUBTLE SHADOW
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  ),
                  title: Text("Dr. ${rec['doctor_name']}", 
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reason: ${rec['reason']}", style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text("${rec['appointment_time'] ?? 'Not set'}", 
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(rec['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rec['status'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(rec['status']),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ],
        );
      },
    );
  }

  // Helper for Status Colors
  Color _getStatusColor(dynamic status) {
    switch (status.toString().toLowerCase()) {
      case 'pending': return Colors.orange.shade700;
      case 'approved': return Colors.green.shade700;
      case 'cancelled': return Colors.red.shade700;
      default: return Colors.grey;
    }
  }

  Future<void> _generateAISummary(List<Map<String, dynamic>> appointments) async {
    if (appointments.isEmpty) return;
    setState(() { _isSummarizing = true; });

    try {
      final history = appointments.map((apt) => 
        "Date: ${apt['appointment_date']}, Reason: ${apt['reason']}").join("\n");
      
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "google/gemini-2.0-flash-lite-001", 
          "messages": [{"role": "user", "content": "Summarize this medical history in 3 short bullet points:\n\n$history"}]
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _aiSummary = jsonDecode(response.body)['choices'][0]['message']['content'];
          _isSummarizing = false;
        });
      }
    } catch (e) {
      setState(() => _isSummarizing = false);
    }
  }
}
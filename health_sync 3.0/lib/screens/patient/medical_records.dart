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
      // LISTEN TO REAL-TIME UPDATES
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
                  borderRadius: BorderRadius.circular(8), 
                  border: Border.all(color: Colors.amber.shade200)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("AI Insight", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(_aiSummary!, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _isSummarizing ? null : () => _generateAISummary(records),
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isSummarizing ? "Analyzing History..." : "Summarize with AI"),
              ),

            const SizedBox(height: 20),
            const Text("Recent Visits", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const Divider(),

            if (records.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No records found.", style: TextStyle(color: Colors.black)),
              )),

            // DISPLAY LIST
            ...records.map((rec) => Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text("Dr. ${rec['doctor_name']}", 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Text("Reason: ${rec['reason']}\nStatus: ${rec['status']}", 
                  style: const TextStyle(color: Colors.black87)),
                isThreeLine: true,
              ),
            )).toList(),
          ],
        );
      },
    );
  }

  // --- AI LOGIC RESTORED ---
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
          "messages": [{"role": "user", "content": "Summarize this medical history in 3 bullet points:\n\n$history"}]
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
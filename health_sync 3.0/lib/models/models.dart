class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'patient', 'doctor', 'staff'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class Appointment {
  final String id;
  final String patientId;
  final String doctorName;
  final DateTime dateTime;
  final String reason;
  String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.dateTime,
    required this.reason,
    this.status = 'pending',
  });
}

class MedicalRecord {
  final String id;
  final String patientId;
  final DateTime date;
  final String diagnosis;
  final String prescription;
  final String doctorName;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.date,
    required this.diagnosis,
    required this.prescription,
    required this.doctorName,
  });
}

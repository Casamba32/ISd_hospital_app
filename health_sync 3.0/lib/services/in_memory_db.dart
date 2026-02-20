import '../models/models.dart';

class InMemoryDB {
  static final List<User> _users = [
    User(id: '1', name: 'John Doe', email: 'patient@test.com', role: 'patient'),
    User(id: '2', name: 'Dr. Smith', email: 'doctor@test.com', role: 'doctor'),
    User(id: '3', name: 'Admin User', email: 'admin@test.com', role: 'staff'),
  ];

  static final List<Appointment> _appointments = [];
  static final List<MedicalRecord> _medicalRecords = [];

  static User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  static void createUser(String name, String email, String role) {
    final id = (_users.length + 1).toString();
    _users.add(User(id: id, name: name, email: email, role: role));
  }

  static void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  static List<Appointment> getAppointmentsForPatient(String patientId) {
    return _appointments.where((a) => a.patientId == patientId).toList();
  }

  static List<MedicalRecord> getMedicalRecordsForPatient(String patientId) {
    return _medicalRecords.where((r) => r.patientId == patientId).toList();
  }

  static void addMedicalRecord(MedicalRecord record) {
    _medicalRecords.add(record);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // We keep the "Base" part here so we can add to it later
  final String baseUrl = "http://localhost:1337/api";

  // --- REGISTER FUNCTION ---
  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local/register'), // Now this correctly points to /api/auth/local/register
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      print("User Registered Successfully!");
    } else {
      print("Register Error: ${response.body}");
    }
  }

  // --- LOGIN FUNCTION ---
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local'), // This points to /api/auth/local
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      print("Login Successful!");
      final data = jsonDecode(response.body);
      print("Your Token: ${data['jwt']}");
    } else {
      print("Login Error: ${response.body}");
    }
  }
}
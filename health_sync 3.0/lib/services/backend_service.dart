import 'package:supabase_flutter/supabase_flutter.dart';

class BackendService {
  static final _supabase = Supabase.instance.client;

  /// REAL password change
  static Future<void> changePassword(String newPassword) async {
    // This updates the password for the currently logged-in user in Supabase
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    print('Password updated in Supabase');
  }

  /// REAL logout
  static Future<void> logOut() async {
    // This clears the session and tells the cloud the user is gone
    await _supabase.auth.signOut();
    print('User logged out from Supabase');
  }

  /// Two-factor authentication (Advanced)
  // Note: Supabase supports MFA, but it requires more setup in the dashboard.
  // For now, we can keep this as a dummy or remove it if you aren't using it.
  static Future<void> toggleTwoFactor(bool enable) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('MFA placeholder: ${enable ? "ENABLED" : "DISABLED"}');
  }
}
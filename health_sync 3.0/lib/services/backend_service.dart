class BackendService {
  /// password change
  static Future<void> changePassword(String newPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Dummy implementation: just print to console
    print('Password changed to $newPassword');
  }

  /// two-factor authentication
  static Future<void> toggleTwoFactor(bool enable) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Two-factor authentication is now ${enable ? "ENABLED" : "DISABLED"}');
  }

  /// logout
  static Future<void> logOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('User logged out');
  }
}

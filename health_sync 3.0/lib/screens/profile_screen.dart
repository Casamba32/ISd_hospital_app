import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../main.dart'; // Adjust path to your main.dart

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authUser = Supabase.instance.client.auth.currentUser;
    final String name = authUser?.userMetadata?['name'] ?? 'Guest';
    final String email = authUser?.email ?? 'No email found';

    // This builder listens for language changes and REBUILDS the whole screen
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, currentLang, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),
            
            // Profile Header
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, size: 60, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 32),
            // TRANSLATED: Settings Header
            Text(
              AppTexts.tr('settings'), 
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
            ),
            const Divider(),

            // --- DARK MODE TOGGLE ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeManager.themeModeNotifier,
                builder: (context, currentMode, _) {
                  final isDark = currentMode == ThemeMode.dark;
                  return SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.amber : Colors.blue,
                    ),
                    // TRANSLATED: Dark Mode
                    title: Text(AppTexts.tr('dark_mode')),
                    subtitle: Text(isDark ? AppTexts.tr('on') : AppTexts.tr('off')),
                    value: isDark,
                    onChanged: (bool value) => ThemeManager.toggleTheme(value),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // --- LANGUAGE SELECTOR ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(Icons.language, color: Colors.blue.shade700),
                // TRANSLATED: App Language
                title: Text(AppTexts.tr('language')),
                trailing: DropdownButton<String>(
                  value: currentLang,
                  underline: const SizedBox(),
                  onChanged: (newValue) => LanguageManager.updateLanguage(newValue),
                  items: LanguageManager.languages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // TRANSLATED: Account Settings
            _buildProfileOption(
              context,
              icon: Icons.settings,
              title: AppTexts.tr('account_settings'),
              onTap: () => Navigator.pushNamed(context, '/account-settings'),
            ),
            
            // TRANSLATED: Help & Support
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: AppTexts.tr('help_support'),
              onTap: () {},
            ),

            const SizedBox(height: 16),
            
            // --- LOGOUT ---
            Card(
              elevation: 0,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade100),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                // TRANSLATED: Logout
                title: Text(
                  AppTexts.tr('logout'),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushReplacementNamed('/login');
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileOption(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
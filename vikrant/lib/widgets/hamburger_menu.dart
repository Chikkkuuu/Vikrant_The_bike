import 'package:flutter/material.dart';
import '../data/mobiledata.dart';
import '../screens/profile_page.dart';
import '../screens/premium_page.dart';
import '../screens/settings_page.dart';
import '../screens/vikrant_play_mode_page.dart';
import '../screens/onboardingscreen.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey.shade900),
            child: const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Nico Moji')),
          ),
          _drawerItem(context, Icons.person, 'Profile', const ProfilePage()),
          _drawerItem(context, Icons.diamond, 'Premium', const PremiumPage()),
          _drawerItem(context, Icons.videogame_asset, 'Vikrant Play Mode', const VikrantPlayModePage()),
          _drawerItem(context, Icons.settings, 'Settings', const SettingsPage()),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Logout', style: TextStyle(color: Colors.white, fontFamily: 'Nico Moji')),
            onTap: () async {
              await clearAllData(); // From mobile_data.dart
              stopFirebaseSyncTimer();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Nico Moji')),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}

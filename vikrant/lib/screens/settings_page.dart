import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  String theme = "Dark";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Nico Moji', color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: notifications,
            onChanged: (val) => setState(() => notifications = val),
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: const Text('Theme', style: TextStyle(color: Colors.white)),
            subtitle: Text(theme, style: const TextStyle(color: Colors.white70)),
            onTap: () => setState(() => theme = theme == "Dark" ? "Light" : "Dark"),
          ),
          const ListTile(
            title: Text('Software Version', style: TextStyle(color: Colors.white)),
            subtitle: Text('v1.0.0', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

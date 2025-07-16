import 'package:flutter/material.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Low Battery",
      "message": "Battery dropped below 20%",
      "time": "5 min ago"
    },
    {
      "title": "High Speed",
      "message": "Speed exceeded 80 km/h",
      "time": "10 min ago"
    },
    {
      "title": "Bike Charged",
      "message": "Battery fully charged",
      "time": "1 hr ago"
    },
  ];

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Nico Moji',
            fontSize: 24,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final note = notifications[index];
          return NotificationCard(
            title: note["title"]!,
            message: note["message"]!,
            time: note["time"]!,
          );
        },
      ),
    );
  }
}

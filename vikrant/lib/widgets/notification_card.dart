import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Nico Moji',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Nico Moji',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontFamily: 'Nico Moji',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

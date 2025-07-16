import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/signin_form.dart';
import '../data/mobiledata.dart';
import '../screens/dashboard.dart';
import 'package:firebase_database/firebase_database.dart';

import '../widgets/signup_form.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final databaseRef = FirebaseDatabase.instance.ref();
  bool _checkingAutoLogin = true;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    if (savedEmail != null &&
        savedPassword != null &&
        savedBikeNumber != null &&
        savedEmail!.isNotEmpty &&
        savedPassword!.isNotEmpty &&
        savedBikeNumber!.isNotEmpty) {
      final emailSnap = await databaseRef
          .child("user_details")
          .orderByChild("user_emailId")
          .equalTo(savedEmail!)
          .once();

      if (!emailSnap.snapshot.exists) {
        setState(() => _checkingAutoLogin = false);
        return;
      }

      final data = Map<String, dynamic>.from(emailSnap.snapshot.value as Map);
      bool matched = false;
      data.forEach((key, value) {
        final user = Map<String, dynamic>.from(value);
        if (user['user_password'] == savedPassword) {
          matched = true;
        }
      });

      if (!matched) {
        setState(() => _checkingAutoLogin = false);
        return;
      }

      final bikeSnap = await databaseRef
          .child("bike")
          .child(savedBikeNumber!)
          .child("bike_Details")
          .child("bike_email_id")
          .get();

      if (!bikeSnap.exists) {
        setState(() => _checkingAutoLogin = false);
        return;
      }

      // ✅ Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(bikeNumber: savedBikeNumber!),
        ),
      );
    } else {
      setState(() => _checkingAutoLogin = false);
    }
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((255 * 0.6).toInt()),
      builder: (context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Dialog(
                backgroundColor: Colors.white.withAlpha((255 * 0.15).toInt()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 475,
                      ),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: Colors.cyanAccent,
                              unselectedLabelColor: Colors.white70,
                              indicatorColor: Colors.cyanAccent,
                              tabs: [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: const SignInForm(),
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: const SignUpForm(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/unsplash_X6hEndRsYhQ.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground Content
          if (!_checkingAutoLogin)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome to Vikrant Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nico Moji',
                      fontSize: 28,
                      color: Color.fromRGBO(175, 238, 238, 0.75),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 596),
                  const Text(
                    'Your companion for safe and smart rides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(175, 238, 238, 0.75),
                      foregroundColor: Colors.black,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 102, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showAuthDialog(context),
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
        ],
      ),
    );
  }
}

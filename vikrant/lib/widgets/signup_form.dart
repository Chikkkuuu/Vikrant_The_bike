import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/mobiledata.dart'; // contains: emailOtp, savedUserKey, etc.

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  final databaseRef = FirebaseDatabase.instance.ref();
  bool signUpComplete = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    emailResendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack("Please enter a valid email address.");
      return;
    }

    final userSnapshot = await databaseRef
        .child("user_details")
        .orderByChild("user_emailId")
        .equalTo(email)
        .once();

    if (userSnapshot.snapshot.exists) {
      _showSnack("Email is already registered.");
      return;
    }

    emailOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    emailOtpExpiry = DateTime.now().add(const Duration(minutes: 5));
    otpDestination = email;
    final formattedTime = DateFormat.jm().format(emailOtpExpiry!);

    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': 'service_i272oyn',
          'template_id': 'template_7b4w7ho',
          'user_id': 'LWrTcsvtET2_umFbQ',
          'template_params': {
            'user_email': email,
            'passcode': emailOtp,
            'time': formattedTime,
          },
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          emailOtpSent = true;
          emailOtpVerified = false;
          _startResendTimer();
        });
        _showSnack("OTP sent to $otpDestination");
      } else {
        _showSnack("Failed to send OTP: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error sending OTP: $e");
    }
  }

  void _startResendTimer() {
    emailResendTimer?.cancel();
    emailResendSeconds = 60;
    emailResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (emailResendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          emailResendSeconds--;
        });
      }
    });
  }

  void _verifyOtp() {
    final inputOtp = _otpController.text.trim();

    if (emailOtpExpiry == null || DateTime.now().isAfter(emailOtpExpiry!)) {
      _showSnack("OTP has expired. Please request a new one.");
      return;
    }

    if (inputOtp == emailOtp) {
      setState(() => emailOtpVerified = true);
      _showSnack("OTP Verified");
    } else {
      _showSnack("Invalid OTP");
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (!emailOtpVerified) {
      _showSnack("Please verify OTP first");
      return;
    }

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack("All fields are required");
      return;
    }

    if (password != confirm) {
      _showSnack("Passwords do not match");
      return;
    }

    try {
      final newUserRef = databaseRef.child("user_details").push();
      final userKey = newUserRef.key;

      await newUserRef.set({
        "user_emailId": email,
        "user_password": password,
        "bike_number": "",
        "user_location": "",
      });

      // Save to mobiledata + SharedPreferences
      await saveLoginData(email, password, '', userKey!);

      setState(() {
        signUpComplete = true;
      });
    } catch (e) {
      _showSnack("Error writing to Firebase: $e");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (signUpComplete) {
      return const Center(
        child: Text(
          "✅ Account Created!\nPlease go to the Sign In page.",
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _input(_emailController, 'Email'),
          _input(_passwordController, 'Password', obscure: true),
          _input(_confirmPasswordController, 'Confirm Password', obscure: true),
          const SizedBox(height: 12),
          if (!emailOtpSent)
            ElevatedButton(onPressed: _sendOtp, child: const Text('Send OTP')),
          if (emailOtpSent && !emailOtpVerified) ...[
            Row(
              children: [
                Expanded(child: _input(_otpController, 'Enter OTP')),
                ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify')),
              ],
            ),
            Text(emailResendSeconds > 0
                ? "Resend OTP in $emailResendSeconds seconds"
                : "Didn't get the code?"),
            if (emailResendSeconds == 0)
              TextButton(onPressed: _sendOtp, child: const Text("Resend OTP")),
          ],
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withAlpha(25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

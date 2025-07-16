import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/mobiledata.dart';
import '../screens/dashboard.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _bikeNumber = TextEditingController();
  final _otp = TextEditingController();

  final databaseRef = FirebaseDatabase.instance.ref();

  bool emailVerified = false;
  bool bikeOtpSent = false;
  bool bikeOtpVerified = false;

  Timer? resendBikeTimer;
  int bikeResendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadAndPrefillData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((savedEmail?.isNotEmpty ?? false) &&
          (savedPassword?.isNotEmpty ?? false) &&
          (savedBikeNumber?.isNotEmpty ?? false)) {
        _verifyEmailAndPassword(auto: true).then((_) {
          if (emailVerified) {
            bikeOtpVerified = true;
            _goToDashboard();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    resendBikeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndPrefillData() async {
    await loadSavedData();

    if ((savedEmail?.isNotEmpty ?? false)) _email.text = savedEmail!;
    if ((savedPassword?.isNotEmpty ?? false)) _password.text = savedPassword!;
    if ((savedBikeNumber?.isNotEmpty ?? false)) _bikeNumber.text = savedBikeNumber!;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _verifyEmailAndPassword({bool auto = false}) async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!auto) _showSnack("Email and password are required");
      return;
    }

    final snapshot = await databaseRef
        .child("user_details")
        .orderByChild("user_emailId")
        .equalTo(email)
        .once();

    if (!snapshot.snapshot.exists) {
      if (!auto) _showSnack("Email not registered");
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
    bool matched = false;
    String? userKey;

    data.forEach((key, value) {
      final user = Map<String, dynamic>.from(value);
      if (user['user_password'] == password) {
        matched = true;
        userKey = key;
      }
    });

    if (!matched) {
      if (!auto) _showSnack("Incorrect password");
      return;
    }

    setState(() {
      emailVerified = true;
    });

    savedBikeNumber = _bikeNumber.text.trim(); // optional prefill

    // ✅ Save login data with userKey
    await saveLoginData(email, password, savedBikeNumber ?? '', userKey!);

    _showSnack("Email verified. Please enter your bike number.");
  }


  Future<void> _sendBikeOtp() async {
    final bikeNum = _bikeNumber.text.trim();

    if (bikeNum.isEmpty) {
      _showSnack("Bike number is required");
      return;
    }

    final snap = await databaseRef
        .child("bike")
        .child(bikeNum)
        .child("bike_Details")
        .child("bike_email_id")
        .get();

    if (!snap.exists) {
      _showSnack("Bike number not registered");
      return;
    }

    final recipientEmail = snap.value.toString();

    bikeOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    bikeOtpExpiry = DateTime.now().add(const Duration(minutes: 5));
    final formattedTime = DateFormat.jm().format(bikeOtpExpiry!);

    final response = await http.post(
      Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'service_i272oyn',
        'template_id': 'template_anssxzf',
        'user_id': 'LWrTcsvtET2_umFbQ',
        'template_params': {
          'email': recipientEmail,
          'passcode': bikeOtp,
          'time': formattedTime,
        },
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        bikeOtpSent = true;
        bikeOtpVerified = false;
        _startBikeResendTimer();
      });

      await saveLoginData(savedEmail ?? '', savedPassword ?? '', bikeNum, savedUserKey ?? '');
      _showSnack("OTP sent to $recipientEmail");
    } else {
      _showSnack("Failed to send OTP");
    }
  }

  void _startBikeResendTimer() {
    resendBikeTimer?.cancel();
    bikeResendSeconds = 60;
    resendBikeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bikeResendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          bikeResendSeconds--;
        });
      }
    });
  }

  void _verifyBikeOtp() async {
    final inputOtp = _otp.text.trim();

    if (bikeOtpExpiry == null || DateTime.now().isAfter(bikeOtpExpiry!)) {
      _showSnack("OTP expired. Request new OTP.");
      return;
    }

    if (inputOtp == bikeOtp) {
      final bikeNum = _bikeNumber.text.trim();

      setState(() {
        bikeOtpVerified = true;
      });

      // ✅ Update user record with bike number
      try {
        if (savedUserKey == null || savedUserKey!.isEmpty) {
          _showSnack("User key not found");
          return;
        }

        await databaseRef
            .child("user_details")
            .child(savedUserKey!)
            .update({'user_bikeNumber': bikeNum});

        await saveLoginData(savedEmail ?? '', savedPassword ?? '', bikeNum, savedUserKey!);

        _showSnack("OTP verified. Bike number saved.");
        _goToDashboard();
      } catch (e) {
        _showSnack("Failed to save bike number: $e");
      }
    } else {
      _showSnack("Invalid OTP");
    }
  }


  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(bikeNumber: savedBikeNumber ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!emailVerified) ...[
            _input(_email, 'Email'),
            _input(_password, 'Password', obscure: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _verifyEmailAndPassword,
              child: const Text("Verify Email"),
            ),
          ] else if (!bikeOtpVerified) ...[
            _input(_bikeNumber, 'Bike Number', readOnly: bikeOtpSent),
            const SizedBox(height: 12),
            if (!bikeOtpSent)
              ElevatedButton(onPressed: _sendBikeOtp, child: const Text("Send OTP")),
            if (bikeOtpSent) ...[
              Row(
                children: [
                  Expanded(child: _input(_otp, 'Enter OTP')),
                  ElevatedButton(onPressed: _verifyBikeOtp, child: const Text("Verify")),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                bikeResendSeconds > 0
                    ? "Resend OTP in $bikeResendSeconds seconds"
                    : "Didn't get the code?",
                style: const TextStyle(color: Colors.white70),
              ),
              if (bikeResendSeconds == 0)
                TextButton(onPressed: _sendBikeOtp, child: const Text("Resend OTP")),
            ],
          ],
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, {bool obscure = false, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: c,
        obscureText: obscure,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: readOnly
              ? Colors.white.withAlpha(15)
              : Colors.white.withAlpha(25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

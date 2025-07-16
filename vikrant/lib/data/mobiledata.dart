import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

// ✅ Persistent Saved Credentials
String? savedEmail = '';
String? savedPassword = '';
String? savedBikeNumber = '';
String? savedUserKey = '';

// ✅ User Profile Info
String? savedName = '';
int? savedAge;
String? savedProfileImage;

// ✅ Flags for OTP logic
bool emailPreviouslyVerified = false;
bool bikePreviouslyVerified = false;
DateTime? lastLoginTime;

String emailOtp = '';
DateTime? emailOtpExpiry;
bool emailOtpSent = false;
bool emailOtpVerified = false;
Timer? emailResendTimer;
int emailResendSeconds = 0;

String bikeOtp = '';
String otpDestination = '';
DateTime? bikeOtpExpiry;
bool bikeOtpSent = false;
bool bikeOtpVerified = false;
Timer? bikeResendTimer;
int bikeResendSeconds = 0;

// ✅ Firebase location sync timer
Timer? firebaseSyncTimer;

/// ✅ Load all saved data from SharedPreferences
Future<void> loadSavedData() async {
  final prefs = await SharedPreferences.getInstance();
  savedEmail = prefs.getString('savedEmail') ?? '';
  savedPassword = prefs.getString('savedPassword') ?? '';
  savedBikeNumber = prefs.getString('savedBikeNumber') ?? '';
  savedUserKey = prefs.getString('savedUserKey') ?? '';
  savedName = prefs.getString('savedName') ?? '';
  savedAge = prefs.getInt('savedAge');
  savedProfileImage = prefs.getString('savedProfileImage');
}

/// ✅ Save login credentials
Future<void> saveLoginData(String email, String password, String bikeNumber, String userKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedEmail', email);
  await prefs.setString('savedPassword', password);
  await prefs.setString('savedBikeNumber', bikeNumber);
  await prefs.setString('savedUserKey', userKey);

  savedEmail = email;
  savedPassword = password;
  savedBikeNumber = bikeNumber;
  savedUserKey = userKey;
}

/// ✅ Save profile info
Future<void> saveProfileInfo(String name, int age) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedName', name);
  await prefs.setInt('savedAge', age);

  savedName = name;
  savedAge = age;
}

/// ✅ Save profile image path
Future<void> saveProfileImage(String path) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedProfileImage', path);
  savedProfileImage = path;
}

/// ✅ Clear all saved data
Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  savedEmail = '';
  savedPassword = '';
  savedBikeNumber = '';
  savedName = '';
  savedAge = 0;
  savedProfileImage = '';
}

/// ✅ Start syncing bike location to Firebase every 1 minute
void startFirebaseSyncTimer() {
  firebaseSyncTimer?.cancel(); // Cancel if already running

  firebaseSyncTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latitude = position.latitude.toString();
      final longitude = position.longitude.toString();

      if (savedBikeNumber == null || savedBikeNumber!.isEmpty) return;

      final ref = FirebaseDatabase.instance
          .ref()
          .child("userdetails")
          .child(savedBikeNumber!);

      await ref.update({
        "bike_number": savedBikeNumber,
        "latitude": latitude,
        "longitude": longitude,
        "timestamp": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("🔥 Error syncing location to Firebase: $e");
    }
  });
}

/// ✅ Stop syncing
void stopFirebaseSyncTimer() {
  firebaseSyncTimer?.cancel();
  firebaseSyncTimer = null;
}

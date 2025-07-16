import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'data/mobiledata.dart';
import 'screens/splashscreen.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';// Required if you used `flutterfire configure`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedData();
  await initializeDateFormatting();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VikrantConnectApp());
}

class VikrantConnectApp extends StatelessWidget {
  const VikrantConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VikrantConnectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

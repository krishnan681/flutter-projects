// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'supabase/supabase.dart';
import 'utils/splash_screen.dart';
import 'screens/homepage_shell.dart'; // ← Import the shell
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celfon5G+ Phone Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const Stage4Splash(),
      routes: {
        '/home': (context) => const HomePageShell(), // ← Use Shell here!
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

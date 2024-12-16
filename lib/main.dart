import 'package:ecoearn/screens/screen_navigation/navigation_screens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart'; // Import the onboarding screen
import 'screens/auth/sign_in/sign_in_screen.dart';
import 'screens/auth/sign_up/sign_up_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(kIsWeb ? const AdminApp() : const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EcoEarn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        textTheme: GoogleFonts.latoTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(), // Your initial screen
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/verify-email': (context) => const EmailVerificationScreen(),
        '/home': (context) => const NavigationScreens(),
      },
    );
  }
}

// Add this new class for Admin Web App
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EcoEarn Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        textTheme: GoogleFonts.latoTextTheme(),
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}

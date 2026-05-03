import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/setup/setup_screen.dart';
import 'screens/home/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Still connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ✅ Not logged in → your normal splash/onboarding/login flow
        if (!snapshot.hasData) {
          return const SplashScreen();
        }

        // Logged in → check if setup done
        return FutureBuilder(
          future: context.read<UserProvider>().loadUser(),
          builder: (context, userSnap) {

            if (userSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final user = context.watch<UserProvider>().user;

            // Setup not done → SetupScreen
            if (user == null || !user.onboardingDone) {
              return const SetupScreen();
            }

            // All good → Home
            return const MainShell();
          },
        );
      },
    );
  }
}
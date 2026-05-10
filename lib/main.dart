import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/setup/setup_screen.dart';
import 'screens/home/main_shell.dart';
import 'services/notification_service.dart';          // ← ADD

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();                 // ← ADD
  await NotificationService().requestPermission();    // ← ADD
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

// Everything below stays exactly the same
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (!snapshot.hasData) {
          return const SplashScreen();
        }
        return FutureBuilder(
          future: context.read<UserProvider>().loadUser(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            final user = context.watch<UserProvider>().user;
            if (user == null || !user.onboardingDone) {
              return const SetupScreen();
            }
            return const MainShell();
          },
        );
      },
    );
  }
}
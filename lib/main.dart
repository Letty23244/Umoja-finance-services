import 'package:flutter/material.dart';
import 'package:flutter_application_1/authScreens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'authScreens/login_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Umoja Finance Services',
      theme: ThemeData(
        primaryColor: const Color(0xFF795548), // light brown
        scaffoldBackgroundColor: const Color(0xFFD7E8BA), // light green
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}

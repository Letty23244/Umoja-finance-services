import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authScreens/signup_screen.dart';
import 'authScreens/verfication_screens.dart';
import 'screens/main_navigation.dart';
import 'screens/saving_screens.dart';
import 'screens/splash_screen.dart';
import 'authScreens/login_screens.dart';
import 'authScreens/auth_provider_screen.dart';
import 'Screens/onboardingScreen.dart';
import 'providers/account_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
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
      title: 'Umoja Finance Services',
      theme: ThemeData(
        primaryColor: const Color(0xFF795548),
        scaffoldBackgroundColor: const Color(0xFFD7E8BA),
      ),
      home: const AppEntry(),
      routes: {
        '/login':        (context) => const LoginScreen(),
        '/signup':       (context) => const SignUpScreen(),
        '/verification': (context) {
          final email = ModalRoute.of(context)
                  ?.settings.arguments as String? ?? '';
          return VerificationScreen(email: email);
        },
        '/savings': (context) => const SavingsScreen(),
        '/main':    (context) => const MainNavigation(),
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _initialized = false;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    await context.read<AuthProvider>().init();

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.authenticated) {
      return const MainNavigation();
    }

    if (!_seenOnboarding) {
      return const OnboardingScreen();
    }

    return const LoginScreen();
  }
}
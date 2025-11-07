import 'dart:async';
import 'package:flutter/material.dart';
import 'onboardingScreen.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key}); 

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Move to Onboarding after 3 seconds
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 232, 186),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Image(
              image: AssetImage('images/logo.png'),
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              "Umoja Finance Services",
              style: TextStyle(
                color: Color.fromARGB(255, 250, 250, 250),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                backgroundColor: Color.fromARGB(255, 215, 232, 186)
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

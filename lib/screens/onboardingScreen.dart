// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authScreens/login_screens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // soft background tone
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            buildPage(
              image: 'images/ladies.png',
              title: 'Welcome to Umoja Finance Services',
              description:
                  'Empowering women and communities through savings, loans, and sustainable growth.',
            ),
            buildPage(
              image: 'images/savings.png',
              title: 'Save, Borrow & Invest',
              description:
                  'Manage your savings, apply for affordable loans, and grow your financial future.',
            ),
            buildPage(
              image: 'images/women2.png',
              title: 'Access Anywhere, Anytime',
              description:
                  'join your sacco sisters together ,grow  ,save in building a brighter financial future.',
            ),
          ],
        ),
      ),

      // Bottom navigation buttons
      bottomSheet: isLastPage
          ? SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A), // Umoja light green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            )
          : Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Color(0xFFA1887F)), // light brown
                    ),
                  ),
                  TextButton(
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Color(0xFF8BC34A)), // light green
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 280),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E), // dark brown for strong contrast
          ),
        ),
        const SizedBox(height: 15),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

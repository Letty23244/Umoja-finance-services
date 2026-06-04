import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_screens.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool isChecking = false;
  bool isVerified = false;

  // 🔥 CHECK VERIFICATION STATUS FROM BACKEND
  Future<void> checkVerification() async {
    setState(() => isChecking = true);

    try {
      final response = await http.post(
        Uri.parse("https://umoja-financial-services-backend.onrender.com/api/check-verification"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => isChecking = false);

      if (response.statusCode == 200) {
        setState(() {
          isVerified = data['verified'] ?? false;
        });

        if (isVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email verified successfully!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not verified yet.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error checking status")),
        );
      }
    } catch (e) {
      setState(() => isChecking = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7E8BA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo.png', height: 100),

              const SizedBox(height: 30),

              const Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              const Text(
                "We sent you a verification email.\nClick the link and then press check below.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isChecking ? null : checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF795548),
                  ),
                  child: isChecking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Check Verification"),
                ),
              ),

              const SizedBox(height: 20),

              if (isVerified)
                const Text(
                  "Email Verified ✔",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
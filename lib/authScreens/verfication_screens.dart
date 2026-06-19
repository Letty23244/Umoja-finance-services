import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFD7E8BA);
  static const String _baseUrl =
      'https://umoja-financial-services-backend.onrender.com/api';

  bool _isChecking  = false;
  bool _isResending = false;

  // Auto-poll every 5 seconds to detect when user clicks the link
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Start polling so the app detects verification automatically
    _startPolling();
  }

  // ── Poll /api/email/status every 5s ───────────────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerification(silent: true);
    });
  }

  // ── GET /api/email/status — uses existing controller ──────
  Future<void> _checkVerification({bool silent = false}) async {
    if (!silent) setState(() => _isChecking = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (!silent) _showSnack('Session expired. Please register again.', success: false);
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/email/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isVerified = data['email_verified'] == true;

        if (isVerified) {
          _pollTimer?.cancel();
          if (mounted) {
            _showSnack('Email verified! Welcome to Umoja Finance 🎉',
                success: true);
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          if (!silent) {
            _showSnack('Email not verified yet. Please check your inbox.',
                success: false);
          }
        }
      }
    } catch (_) {
      // Silent polling errors are ignored
      if (!silent) {
        _showSnack('Could not check status. Please try again.', success: false);
      }
    } finally {
      if (mounted && !silent) setState(() => _isChecking = false);
    }
  }

  // ── POST /api/email/resend — uses existing controller ─────
  Future<void> _resendEmail() async {
    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/resend'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': widget.email}),
      ).timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      _showSnack(
        data['message'] ?? 'Verification email sent.',
        success: response.statusCode == 200,
      );
    } catch (e) {
      _showSnack('Failed to resend. Please try again.', success: false);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [

              // ── Logo ────────────────────────────────────
              Image.asset('images/logo.png', height: 90),
              const SizedBox(height: 32),

              // ── Animated email icon ──────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryBrown.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    color: primaryBrown, size: 56),
              ),
              const SizedBox(height: 28),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to',
                style: TextStyle(fontSize: 14, color: Colors.brown.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown),
              ),
              const SizedBox(height: 32),

              // ── Steps card ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.brown.shade100, blurRadius: 12)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Follow these steps:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                            fontSize: 14)),
                    const SizedBox(height: 16),
                    _step('1', 'Open your email inbox'),
                    _step('2', 'Find the email from Umoja Finance'),
                    _step('3', 'Tap the verification link'),
                    _step('4', 'Come back here — the app detects it automatically'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Auto-detecting notice
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: lightGreen.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      height: 14, width: 14,
                      child: CircularProgressIndicator(
                          color: primaryBrown, strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Checking verification status automatically…',
                        style: TextStyle(
                            fontSize: 12,
                            color: primaryBrown,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── I've verified button ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: _isChecking
                      ? null
                      : () => _checkVerification(silent: false),
                  icon: _isChecking
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              color: lightGreen, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.check_circle_outline,
                          color: lightGreen, size: 20),
                  label: Text(
                    _isChecking ? 'Checking…' : "I've Verified My Email",
                    style: const TextStyle(
                        color: lightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Resend button ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryBrown, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isResending ? null : _resendEmail,
                  icon: _isResending
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(
                              color: primaryBrown, strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh,
                          color: primaryBrown, size: 20),
                  label: Text(
                    _isResending ? 'Sending…' : 'Resend Verification Email',
                    style: const TextStyle(
                        color: primaryBrown,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Wrong email ──────────────────────────────
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Wrong email? Go back',
                  style: TextStyle(color: Colors.brown, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),

              // ── Spam notice ──────────────────────────────
              Text(
                "Don't see the email? Check your spam folder.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Colors.brown.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: const BoxDecoration(
                color: primaryBrown, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}
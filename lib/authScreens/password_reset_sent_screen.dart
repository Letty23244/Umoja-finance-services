import 'dart:async';
import 'package:flutter/material.dart';
import 'package:umoja_finance_services/authScreens/auth_services_screen.dart';

class PasswordResetSentScreen extends StatefulWidget {
  final String email;

  const PasswordResetSentScreen({super.key, required this.email});

  @override
  State<PasswordResetSentScreen> createState() =>
      _PasswordResetSentScreenState();
}

class _PasswordResetSentScreenState extends State<PasswordResetSentScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFFD7E8BA);
  static const Color bgColor = Color(0xFFF5F5F0);

  bool _isResending = false;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final result = await AuthService().forgotPassword(widget.email);
      if (mounted) {
        _showSnack(
          result.message ??
              (result.isSuccess ? 'Reset link resent!' : 'Failed to resend.'),
          success: result.isSuccess,
        );
        if (result.isSuccess) _startTimer();
      }
    } catch (e) {
      _showSnack(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
        success: false,
      );
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Check Your Email',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            // ── Icon ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBrown.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: primaryBrown,
                size: 56,
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Reset Link Sent!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBrown,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We\'ve sent a password reset link to',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryBrown,
              ),
            ),
            const SizedBox(height: 32),

            // ── Steps card ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _step('1', 'Open your email inbox'),
                  _step('2', 'Find the email from Umoja Finance'),
                  _step('3', 'Tap the reset link in the email'),
                  _step('4', 'Set your new password in the browser'),
                  _step('5', 'Come back and log in with your new password'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Spam notice ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: lightGreen.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: primaryBrown, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Don\'t see the email? Check your spam or junk folder.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Resend ───────────────────────────────────
            _secondsLeft > 0
                ? Text(
                    'Resend link in $_secondsLeft seconds',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBrown, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isResending ? null : _resend,
                      icon: _isResending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: primaryBrown,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: primaryBrown,
                              size: 18,
                            ),
                      label: Text(
                        _isResending ? 'Sending…' : 'Resend Reset Link',
                        style: const TextStyle(
                          color: primaryBrown,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // ── Back to login ────────────────────────────
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              icon: const Icon(Icons.login, color: primaryBrown, size: 18),
              label: const Text(
                'Back to Login',
                style: TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
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
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: primaryBrown,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

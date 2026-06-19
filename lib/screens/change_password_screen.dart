import 'package:flutter/material.dart';
import 'package:umoja_finance_services/authScreens/auth_services_screen.dart';
import 'package:umoja_finance_services/authScreens/password_reset_sent_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFFD7E8BA);
  static const Color bgColor = Color(0xFFF5F5F0);

  bool _isLoading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) setState(() => _userEmail = user?.email);
  }

  Future<void> _sendResetLink() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      _showSnack(
        'Could not load your email. Please try again.',
        success: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().forgotPassword(_userEmail!);

      if (result.isSuccess) {
        if (mounted) {
          // Navigate to the waiting screen (same pattern as email verification)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordResetSentScreen(email: _userEmail!),
            ),
          );
        }
      } else {
        _showSnack(
          result.message ?? result.errorMessage ?? 'Failed to send reset link.',
          success: false,
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Banner ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryBrown,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: lightGreen,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We\'ll send a reset link to your email address',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ── Email display tile ─────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: primaryBrown,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reset link will be sent to',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _userEmail == null
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: primaryBrown,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _userEmail!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBrown,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Info box ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightGreen),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.info_outline,
                          'A password reset link will be sent to your registered email address.',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.timer_outlined,
                          'The link will expire after 60 minutes.',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.mail_outline,
                          'Check your spam folder if you don\'t see it in your inbox.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Send button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: (_isLoading || _userEmail == null)
                          ? null
                          : _sendResetLink,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: lightGreen,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_outlined,
                              color: lightGreen,
                              size: 18,
                            ),
                      label: Text(
                        _isLoading ? 'Sending…' : 'Send Reset Link',
                        style: const TextStyle(
                          color: lightGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryBrown, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: primaryBrown),
          ),
        ),
      ],
    );
  }
}

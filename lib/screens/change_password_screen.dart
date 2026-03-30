import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  final _formKey        = GlobalKey<FormState>();
  final _oldController  = TextEditingController();
  final _newController  = TextEditingController();
  final _confController = TextEditingController();

  bool _obscureOld     = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  // Password strength
  String _strength     = '';
  Color  _strengthColor = Colors.grey;

  void _checkStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        _strength = '';
        _strengthColor = Colors.grey;
      } else if (value.length < 6) {
        _strength = 'Weak';
        _strengthColor = Colors.red;
      } else if (value.length < 10) {
        _strength = 'Medium';
        _strengthColor = Colors.orange;
      } else {
        _strength = 'Strong';
        _strengthColor = Colors.green;
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1)); // simulate API call
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    child: const Icon(Icons.lock_reset, color: lightGreen, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Update Your Password',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keep your account secure with a strong password',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Form ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Current Password
                    const Text('Current Password', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _oldController,
                      hint: 'Enter current password',
                      obscure: _obscureOld,
                      toggle: () => setState(() => _obscureOld = !_obscureOld),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your current password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // New Password
                    const Text('New Password', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _newController,
                      hint: 'Enter new password',
                      obscure: _obscureNew,
                      toggle: () => setState(() => _obscureNew = !_obscureNew),
                      onChanged: _checkStrength,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter a new password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    // Strength indicator
                    if (_strength.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _strength == 'Weak' ? 0.33 : _strength == 'Medium' ? 0.66 : 1.0,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _strength,
                            style: TextStyle(color: _strengthColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Confirm Password
                    const Text('Confirm New Password', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _confController,
                      hint: 'Re-enter new password',
                      obscure: _obscureConfirm,
                      toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password';
                        if (v != _newController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password tips
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lightGreen),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tips_and_updates, color: primaryBrown, size: 16),
                              SizedBox(width: 6),
                              Text('Password Tips', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _tip('Use at least 8 characters'),
                          _tip('Include uppercase and lowercase letters'),
                          _tip('Add numbers and special characters'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: lightGreen, strokeWidth: 2),
                              )
                            : const Text(
                                'Update Password',
                                style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: primaryBrown,
          ),
          onPressed: toggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: primaryBrown, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: primaryBrown)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  // Dummy data
  static const String walletBalance = '2,450,000';
  static const String walletName    = 'My Savings Wallet';

  final _formKey          = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController   = TextEditingController();
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Withdraw Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Header ──────────────────────────────────
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
              child: const Column(
                children: [
                  Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 8),
                  Text(
                    'UGX $walletBalance',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(walletName, style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Form ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Amount
                    const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Enter amount', Icons.attach_money, 'UGX '),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter an amount';
                        if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Withdrawal Method
                    const Text('Withdrawal Method', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _methodCard('Mobile Money', Icons.phone_android, 'Mobile'),
                        const SizedBox(width: 10),
                        _methodCard('Bank Transfer', Icons.account_balance, 'Bank'),
                        const SizedBox(width: 10),
                        _methodCard('Cash Pickup', Icons.storefront, 'Cash'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Description (optional)', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: _inputDecoration('e.g. Emergency funds', Icons.note_outlined, null),
                    ),
                    const SizedBox(height: 24),

                    // How it works
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
                              Icon(Icons.info_outline, color: primaryBrown, size: 16),
                              SizedBox(width: 6),
                              Text('How it works', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _step('1', 'Enter the amount to withdraw'),
                          _step('2', 'Select your withdrawal method'),
                          _step('3', 'Tap Withdraw to confirm'),
                          _step('4', 'Receive confirmation instantly'),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedMethod == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a withdrawal method'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _showSuccessSheet();
                          }
                        },
                        child: const Text(
                          'Withdraw Funds',
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

  // ── Method Card ────────────────────────────────────────────
  Widget _methodCard(String label, IconData icon, String value) {
    final isSelected = _selectedMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? primaryBrown : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryBrown : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? lightGreen : primaryBrown, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? lightGreen : primaryBrown,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success Sheet ──────────────────────────────────────────
  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdrawal Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBrown),
            ),
            const SizedBox(height: 8),
            Text(
              'UGX ${_amountController.text} has been withdrawn via $_selectedMethod',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _amountController.clear();
                  _descController.clear();
                  setState(() => _selectedMethod = null);
                },
                child: const Text('Done', style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step ───────────────────────────────────────────────────
  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: primaryBrown),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: primaryBrown)),
        ],
      ),
    );
  }

  // ── Input Decoration ───────────────────────────────────────
  InputDecoration _inputDecoration(String hint, IconData icon, String? prefix) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(icon, color: primaryBrown),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryBrown, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
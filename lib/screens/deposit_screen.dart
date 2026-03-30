import 'package:flutter/material.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color darkGreen    = Color(0xFF4CAF50);
  static const Color bgColor      = Color(0xFFF5F5F0);

  final _formKey          = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController   = TextEditingController();

  String? _selectedMethod;
  bool _isLoading = false;

  // Dummy wallet balance
  static const String dummyBalance = '500,000';
  static const String walletName   = 'My Savings Wallet';

  void _deposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      _showSnackbar('Please select a deposit method', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    setState(() => _isLoading = false);

    _showSuccessSheet();
    _amountController.clear();
    _descController.clear();
    setState(() => _selectedMethod = null);
  }

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
                color: darkGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deposit Successful! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBrown),
            ),
            const SizedBox(height: 8),
            Text(
              'UGX ${_amountController.text} deposited',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Done', style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Deposit Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.arrow_downward_rounded, color: lightGreen, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text(
                    'UGX $dummyBalance',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(walletName, style: TextStyle(color: Colors.white60, fontSize: 12)),
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
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quick amounts
                    const Text('Quick Amount', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['50,000', '100,000', '200,000', '500,000'].map((amount) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() =>
                                _amountController.text = amount.replaceAll(',', '')),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  amount,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: primaryBrown, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Deposit Method
                    const Text('Deposit Method', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _methodCard('Mobile Money', Icons.phone_android, 'Mobile'),
                        const SizedBox(width: 10),
                        _methodCard('Bank Transfer', Icons.account_balance, 'Bank'),
                        const SizedBox(width: 10),
                        _methodCard('Cash', Icons.payments_outlined, 'Cash'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Description (optional)', style: TextStyle(fontWeight: FontWeight.w600, color: primaryBrown, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: _inputDecoration('e.g. Salary deposit', Icons.note_outlined, null),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _deposit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Deposit Funds',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
            border: Border.all(color: isSelected ? primaryBrown : Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? lightGreen : primaryBrown, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? lightGreen : primaryBrown),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
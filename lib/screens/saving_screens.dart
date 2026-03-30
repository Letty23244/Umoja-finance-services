import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/balance_card.dart';
import 'package:flutter_application_1/widget/transaction_card.dart';
import 'package:flutter_application_1/widget/action_button.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  // ── Colors ─────────────────────────────────────────────────
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color darkGreen    = Color(0xFF4CAF50);
  static const Color bgColor      = Color(0xFFF5F5F0);

  // ── Dummy Data ─────────────────────────────────────────────
  static const String walletName   = 'My Savings Wallet';
  static const String balance      = '500,000';
  static const String totalDeposit = '1,200,000';
  static const String totalWithdraw = '700,000';

  static const List<Map<String, dynamic>> transactions = [
    {'type': 'deposit',    'description': 'Salary Deposit',   'amount': '500,000', 'date': 'Today'},
    {'type': 'withdrawal', 'description': 'Emergency',        'amount': '50,000',  'date': 'Yesterday'},
    {'type': 'saving',     'description': 'Weekly Savings',   'amount': '30,000',  'date': '18 Mar'},
    {'type': 'deposit',    'description': 'Business Income',  'amount': '150,000', 'date': '17 Mar'},
    {'type': 'withdrawal', 'description': 'Grocery',          'amount': '20,000',  'date': '16 Mar'},
    {'type': 'deposit',    'description': 'Freelance Payment','amount': '200,000', 'date': '15 Mar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Savings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Balance Card ───────────────────────────────
            BalanceCard(
              walletName: walletName,
              balance: balance,
              backgroundColor: primaryBrown,
            ),
            const SizedBox(height: 16),

            // ── Stats Row ──────────────────────────────────
            Row(
              children: [
                Expanded(child: _statCard('Total Deposited', 'UGX $totalDeposit', Icons.arrow_downward, darkGreen)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Total Withdrawn', 'UGX $totalWithdraw', Icons.arrow_upward, Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Action Buttons ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Deposit',
                    icon: Icons.add_rounded,
                    color: darkGreen,
                    onPressed: () => _showTransactionSheet(context, 'deposit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: 'Withdraw',
                    icon: Icons.remove_rounded,
                    color: Colors.redAccent,
                    onPressed: () => _showTransactionSheet(context, 'withdraw'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Transactions ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${transactions.length} records',
                    style: const TextStyle(color: primaryBrown, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transaction filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', true),
                  const SizedBox(width: 8),
                  _filterChip('Deposits', false),
                  const SizedBox(width: 8),
                  _filterChip('Withdrawals', false),
                  const SizedBox(width: 8),
                  _filterChip('Savings', false),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Transactions list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tx = entry.value;
                  return Column(
                    children: [
                      TransactionCard(
                        type: tx['type'],
                        description: tx['description'],
                        amount: tx['amount'],
                        date: tx['date'],
                      ),
                      if (index < transactions.length - 1)
                        Divider(height: 1, indent: 70, endIndent: 16, color: Colors.grey.shade100),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionSheet(context, 'deposit'),
        backgroundColor: primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Stat Card ──────────────────────────────────────────────
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chip ────────────────────────────────────────────
  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primaryBrown : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? primaryBrown : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // ── Transaction Sheet ──────────────────────────────────────
  void _showTransactionSheet(BuildContext context, String type) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              type == 'deposit' ? '💰 Make a Deposit' : '💸 Withdraw Funds',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBrown),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (UGX)',
                prefixText: 'UGX ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBrown),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: type == 'deposit' ? 'e.g. Salary deposit' : 'e.g. Emergency',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBrown),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: type == 'deposit' ? 'Deposit' : 'Withdraw',
                icon: type == 'deposit' ? Icons.add_rounded : Icons.remove_rounded,
                color: type == 'deposit' ? darkGreen : Colors.redAccent,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(type == 'deposit' ? 'Deposit successful!' : 'Withdrawal successful!'),
                      backgroundColor: type == 'deposit' ? darkGreen : Colors.redAccent,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
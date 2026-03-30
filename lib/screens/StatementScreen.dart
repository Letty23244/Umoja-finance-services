import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/transaction_card.dart';

class StatementsScreen extends StatelessWidget {
  const StatementsScreen({super.key});

  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color darkGreen    = Color(0xFF4CAF50);
  static const Color bgColor      = Color(0xFFF5F5F0);

  static const List<Map<String, dynamic>> statements = [
    {'type': 'deposit',    'description': 'Salary Deposit',    'amount': '500,000', 'date': '01 Mar 2026'},
    {'type': 'withdrawal', 'description': 'Emergency',         'amount': '50,000',  'date': '28 Feb 2026'},
    {'type': 'saving',     'description': 'Weekly Savings',    'amount': '30,000',  'date': '25 Feb 2026'},
    {'type': 'deposit',    'description': 'Business Income',   'amount': '150,000', 'date': '20 Feb 2026'},
    {'type': 'withdrawal', 'description': 'Grocery',           'amount': '20,000',  'date': '18 Feb 2026'},
    {'type': 'deposit',    'description': 'Freelance Payment', 'amount': '200,000', 'date': '15 Feb 2026'},
    {'type': 'withdrawal', 'description': 'Electricity Bill',  'amount': '80,000',  'date': '10 Feb 2026'},
    {'type': 'saving',     'description': 'Auto Savings',      'amount': '50,000',  'date': '05 Feb 2026'},
  ];

  // Summary calculations
  static int get totalDeposits => statements
      .where((t) => t['type'] == 'deposit')
      .fold(0, (sum, t) => sum + int.parse(t['amount'].replaceAll(',', '')));

  static int get totalWithdrawals => statements
      .where((t) => t['type'] == 'withdrawal')
      .fold(0, (sum, t) => sum + int.parse(t['amount'].replaceAll(',', '')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Statements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [

          // ── Summary Header ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: primaryBrown,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Summary',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryItem(
                        'Total In',
                        'UGX ${_formatAmount(totalDeposits)}',
                        Icons.arrow_downward_rounded,
                        darkGreen,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _summaryItem(
                        'Total Out',
                        'UGX ${_formatAmount(totalWithdrawals)}',
                        Icons.arrow_upward_rounded,
                        Colors.redAccent,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _summaryItem(
                        'Records',
                        '${statements.length} items',
                        Icons.receipt_long,
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Filter Chips ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
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
          ),

          // ── Statements List ────────────────────────────────
          Expanded(
            child: statements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No statements yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your transactions will appear here',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: statements.length,
                    itemBuilder: (context, index) {
                      final tx = statements[index];

                      // Show month header
                      final showHeader = index == 0 ||
                          tx['date'].toString().substring(3) !=
                              statements[index - 1]['date'].toString().substring(3);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                tx['date'].toString().substring(3),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
                              ],
                            ),
                            child: TransactionCard(
                              type: tx['type'],
                              description: tx['description'],
                              amount: tx['amount'],
                              date: tx['date'],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Summary Item ───────────────────────────────────────────
  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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

  // ── Format Amount ──────────────────────────────────────────
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
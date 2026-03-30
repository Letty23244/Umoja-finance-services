import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color darkGreen    = Color(0xFF4CAF50);
  static const Color bgColor      = Color(0xFFF5F5F0);

  String _selectedFilter = 'All';

  static const List<Map<String, dynamic>> allTransactions = [
    {'title': 'Savings Deposit',  'date': '20 Feb 2026', 'amount': '500,000',   'isCredit': true,  'type': 'deposit',    'icon': Icons.arrow_downward},
    {'title': 'Withdrawal',       'date': '18 Feb 2026', 'amount': '100,000',   'isCredit': false, 'type': 'withdrawal', 'icon': Icons.arrow_upward},
    {'title': 'Auto Savings',     'date': '15 Feb 2026', 'amount': '50,000',    'isCredit': false, 'type': 'saving',     'icon': Icons.autorenew},
    {'title': 'Locked Savings',   'date': '12 Feb 2026', 'amount': '200,000',   'isCredit': false, 'type': 'saving',     'icon': Icons.lock},
    {'title': 'Salary Deposit',   'date': '01 Feb 2026', 'amount': '1,500,000', 'isCredit': true,  'type': 'deposit',    'icon': Icons.arrow_downward},
    {'title': 'Emergency',        'date': '28 Jan 2026', 'amount': '80,000',    'isCredit': false, 'type': 'withdrawal', 'icon': Icons.arrow_upward},
    {'title': 'Business Income',  'date': '25 Jan 2026', 'amount': '300,000',   'isCredit': true,  'type': 'deposit',    'icon': Icons.arrow_downward},
    {'title': 'Weekly Savings',   'date': '20 Jan 2026', 'amount': '30,000',    'isCredit': false, 'type': 'saving',     'icon': Icons.savings},
  ];

  List<Map<String, dynamic>> get filteredTransactions {
    switch (_selectedFilter) {
      case 'Deposits':
        return allTransactions.where((t) => t['type'] == 'deposit').toList();
      case 'Withdrawals':
        return allTransactions.where((t) => t['type'] == 'withdrawal').toList();
      case 'Savings':
        return allTransactions.where((t) => t['type'] == 'saving').toList();
      default:
        return allTransactions;
    }
  }

  double get totalIn => allTransactions
      .where((t) => t['isCredit'] == true)
      .fold(0.0, (sum, t) => sum + double.parse(t['amount'].toString().replaceAll(',', '')));

  double get totalOut => allTransactions
      .where((t) => t['isCredit'] == false)
      .fold(0.0, (sum, t) => sum + double.parse(t['amount'].toString().replaceAll(',', '')));

  @override
  Widget build(BuildContext context) {
    final transactions = filteredTransactions;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [

          // ── Summary Header ─────────────────────────────
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
            child: Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Total In',
                    'UGX ${_formatAmount(totalIn.toInt())}',
                    Icons.arrow_downward_rounded,
                    darkGreen,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _summaryItem(
                    'Total Out',
                    'UGX ${_formatAmount(totalOut.toInt())}',
                    Icons.arrow_upward_rounded,
                    Colors.redAccent,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _summaryItem(
                    'Records',
                    '${allTransactions.length} items',
                    Icons.receipt_long,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Chips ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Deposits', 'Withdrawals', 'Savings'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedFilter == filter ? primaryBrown : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedFilter == filter ? primaryBrown : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: _selectedFilter == filter ? Colors.white : Colors.grey,
                            fontSize: 12,
                            fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Count ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} ${_selectedFilter == 'All' ? 'transactions' : _selectedFilter.toLowerCase()}',
                  style: const TextStyle(color: primaryBrown, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(_selectedFilter, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Transaction List ───────────────────────────
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter.toLowerCase()} found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      // Month header
                      final showHeader = index == 0 ||
                          tx['date'].toString().substring(7) !=
                              transactions[index - 1]['date'].toString().substring(7);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                tx['date'].toString().substring(7),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          _transactionTile(tx),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Tile ───────────────────────────────────────
  Widget _transactionTile(Map<String, dynamic> tx) {
    final isCredit = tx['isCredit'] as bool;
    final color    = isCredit ? darkGreen : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(tx['icon'], color: color, size: 20),
        ),
        title: Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: primaryBrown)),
        subtitle: Text(tx['date'], style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'} UGX ${tx['amount']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isCredit ? 'Credit' : 'Debit',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
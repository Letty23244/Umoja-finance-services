import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umoja_finance_services/providers/account_provider.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  // Filter: 'all' | 'deposit' | 'withdraw'
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().fetchAccountData();
    });
  }

  String _formatAmount(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    // Apply filter
    final filtered = account.transactions.where((tx) {
      if (_filter == 'deposit') return tx.isPositive;
      if (_filter == 'withdraw') return !tx.isPositive;
      return true;
    }).toList();

    // Totals from full list (not filtered)
    double totalDeposits   = 0;
    double totalWithdrawals = 0;
    for (final tx in account.transactions) {
      if (tx.isPositive) {
        totalDeposits += tx.amount;
      } else {
        totalWithdrawals += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Statements',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                context.read<AccountProvider>().fetchAccountData(),
          ),
        ],
      ),
      body: account.isLoading
          ? _buildLoader()
          : RefreshIndicator(
              color: primaryBrown,
              onRefresh: () =>
                  context.read<AccountProvider>().fetchAccountData(),
              child: Column(
                children: [

                  // ── Summary Header ───────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    decoration: const BoxDecoration(
                      color: primaryBrown,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _summaryItem(
                              'Total In',
                              'UGX ${_formatAmount(totalDeposits)}',
                              Icons.arrow_downward_rounded,
                              const Color(0xFF43E97B),
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24),
                            _summaryItem(
                              'Total Out',
                              'UGX ${_formatAmount(totalWithdrawals)}',
                              Icons.arrow_upward_rounded,
                              const Color(0xFFFF6584),
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24),
                            _summaryItem(
                              'Records',
                              '${account.transactions.length}',
                              Icons.receipt_long_outlined,
                              Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Filter chips ─────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _filterChip('All', 'all'),
                            const SizedBox(width: 8),
                            _filterChip('Deposits', 'deposit'),
                            const SizedBox(width: 8),
                            _filterChip('Withdrawals', 'withdraw'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Transaction List ─────────────────────
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final tx = filtered[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: tx.isPositive
                                            ? [
                                                const Color(0xFF43E97B),
                                                const Color(0xFF38F9D7)
                                              ]
                                            : [
                                                const Color(0xFFFF6584),
                                                const Color(0xFFFF8E53)
                                              ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      tx.isPositive
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    tx.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    tx.date,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade400),
                                  ),
                                  trailing: Text(
                                    tx.formattedAmount,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: tx.isPositive
                                          ? const Color(0xFF43E97B)
                                          : const Color(0xFFFF6584),
                                    ),
                                  ),
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

  // ── Filter Chip ────────────────────────────────────────────
  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? lightGreen : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryBrown : Colors.white,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── Summary Item ───────────────────────────────────────────
  Widget _summaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }

  // ── Loader ─────────────────────────────────────────────────
  Widget _buildLoader() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: primaryBrown),
        SizedBox(height: 16),
        Text('Loading statements…',
            style: TextStyle(color: primaryBrown, fontSize: 14)),
      ],
    ),
  );

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              color: lightGreen, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_outlined,
              color: primaryBrown, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          _filter == 'all'
              ? 'No transactions yet'
              : 'No ${_filter}s found',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown),
        ),
        const SizedBox(height: 6),
        const Text('Pull down to refresh',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umoja_finance_services/providers/account_provider.dart';
import 'package:umoja_finance_services/screens/deposit_screen.dart';
import 'package:umoja_finance_services/screens/withdraw_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightBrown   = Color(0xFFA1887F);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().fetchAccountData();
    });
  }

  Future<void> _onRefresh() =>
      context.read<AccountProvider>().fetchAccountData();

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'Today';
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    // Derive deposit/withdraw totals from transaction list
    double totalDeposit  = 0;
    double totalWithdraw = 0;
    for (final tx in account.transactions) {
      if (tx.isPositive) {
        totalDeposit += tx.amount;
      } else {
        totalWithdraw += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'My Savings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: account.isLoading
          ? _buildLoader()
          : RefreshIndicator(
              color: primaryBrown,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Balance Card ─────────────────────────────
                    _buildBalanceCard(account),
                    const SizedBox(height: 16),

                    // ── Deposit / Withdraw Stats ──────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Total Deposited',
                            totalDeposit,
                            Icons.arrow_downward_rounded,
                            const Color(0xFF43E97B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Total Withdrawn',
                            totalWithdraw,
                            Icons.arrow_upward_rounded,
                            const Color(0xFFFF6584),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Quick Actions ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: 'Deposit',
                            icon: Icons.add_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DepositScreen()),
                              );
                              if (mounted) _onRefresh();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            label: 'Withdraw',
                            icon: Icons.remove_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6584), Color(0xFFFF8E53)],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WithdrawScreen(
                                    initialBalance: account.walletBalance,
                                  ),
                                ),
                              );
                              if (mounted) _onRefresh();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Transaction History ───────────────────────
                    Row(
                      children: [
                        Container(
                          width: 4, height: 18,
                          decoration: BoxDecoration(
                            color: primaryBrown,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${account.transactions.length} records',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    account.transactions.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionList(account),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Balance Card ───────────────────────────────────────────
  Widget _buildBalanceCard(AccountProvider account) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF795548), Color(0xFFA1887F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: -20,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white70, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Live balance from AccountProvider
              Text(
                'UGX ${account.formattedWallet}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'As of today',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              // Locked savings sub-stat
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Locked: UGX ${account.formattedLocked}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat Card ──────────────────────────────────────────────
  Widget _statCard(
      String title, double value, IconData icon, Color color) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            'UGX $formatted',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Button ──────────────────────────────────────────
  Widget _actionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ── Transaction List ───────────────────────────────────────
  Widget _buildTransactionList(AccountProvider account) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200,
              blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: account.transactions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1, indent: 70, endIndent: 16,
          color: Colors.grey.shade100,
        ),
        itemBuilder: (context, i) {
          final tx = account.transactions[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tx.isPositive
                      ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
                      : [const Color(0xFFFF6584), const Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              tx.date,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
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
          );
        },
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings_outlined,
                  color: primaryBrown, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown),
            ),
            const SizedBox(height: 6),
            const Text(
              'Make a deposit to get started!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loader ─────────────────────────────────────────────────
  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryBrown),
          SizedBox(height: 16),
          Text('Loading savings…',
              style: TextStyle(color: primaryBrown, fontSize: 14)),
        ],
      ),
    );
  }
}
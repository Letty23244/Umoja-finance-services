import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/saving_screens.dart';
import 'package:flutter_application_1/screens/StatementScreen.dart';
import 'package:flutter_application_1/savings/locked_savings_screen.dart';
import 'package:flutter_application_1/savings/auto_savings_screens.dart';
import 'package:flutter_application_1/savings/savings_goal_screen.dart';
import 'package:flutter_application_1/screens/deposit_screen.dart';
import 'package:flutter_application_1/screens/withdraw_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primary   = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent    = Color(0xFF43E97B);
  static const Color orange    = Color(0xFFFF9F43);
  static const Color bgColor   = Color(0xFFF0F2FF);

  static const String userName      = 'Leticia';
  static const String totalSavings  = '2,450,000';
  static const String walletBalance = '500,000';
  static const String lockedAmount  = '1,200,000';
  static const int    activeGoals   = 3;

  static const List<Map<String, dynamic>> recentTransactions = [
    {'title': 'Savings Deposit', 'amount': '+ UGX 500,000', 'isPositive': true,  'date': 'Today',     'icon': Icons.arrow_downward},
    {'title': 'Auto Savings',    'amount': '- UGX 50,000',  'isPositive': false, 'date': 'Yesterday', 'icon': Icons.autorenew},
    {'title': 'Locked Savings',  'amount': '- UGX 200,000', 'isPositive': false, 'date': '18 Mar',    'icon': Icons.lock},
    {'title': 'Withdrawal',      'amount': '- UGX 100,000', 'isPositive': false, 'date': '17 Mar',    'icon': Icons.arrow_upward},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [

          // ── Pinned App Bar (Greeting only) ─────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 70,
            backgroundColor:Colors.brown,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF795548), Color(0xFF795548)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar + greeting
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              child: Text(
                                'LN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Good Morning 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Notification bell
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Total Savings Card (separate layout) ──────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF795548), Color(0xFF795548)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circle
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),

                      // Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Savings',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      '+12.5%',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'UGX $totalSavings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'As of Today',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 20),

                          // Mini stats inside card
                          Row(
                            children: [
                              _miniStat('Wallet', 'UGX $walletBalance', Icons.account_balance_wallet),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 30, color: Colors.white24),
                              const SizedBox(width: 8),
                              _miniStat('Locked', 'UGX $lockedAmount', Icons.lock),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 30, color: Colors.white24),
                              const SizedBox(width: 8),
                              _miniStat('Goals', '$activeGoals Active', Icons.flag),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Quick Actions ──────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              context,
                              icon: Icons.add_rounded,
                              label: 'Deposit',
                              gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen())),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionCard(
                              context,
                              icon: Icons.remove_rounded,
                              label: 'Withdraw',
                              gradient: const LinearGradient(colors: [Color(0xFFFF6584), Color(0xFFFF8E53)]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              context,
                              icon: Icons.lock_rounded,
                              label: 'Lock Savings',
                              gradient: const LinearGradient(colors: [Color(0xFFFF9F43), Color(0xFFFFD700)]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockedSavingsScreen())),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionCard(
                              context,
                              icon: Icons.autorenew_rounded,
                              label: 'Auto Savings',
                              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF48C6EF)]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoSavingsScreen())),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Savings Goals ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Savings Goals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsGoalScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('View All', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _goalCard('Buy Equipment', 0.40, 'UGX 800K / 2M', const Color(0xFF6C63FF)),
                      const SizedBox(height: 10),
                      _goalCard('Emergency Fund', 0.25, 'UGX 250K / 1M', const Color(0xFFFF6584)),
                      const SizedBox(height: 10),
                      _goalCard('Expand Stock', 1.0, 'UGX 500K / 500K ✓', const Color(0xFF43E97B)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Recent Transactions ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatementsScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('View All', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: recentTransactions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tx = entry.value;
                        return Column(
                          children: [
                            _transactionTile(tx['title'], tx['amount'], tx['isPositive'], tx['date'], tx['icon']),
                            if (index < recentTransactions.length - 1)
                              Divider(height: 1, indent: 70, endIndent: 16, color: Colors.grey.shade100),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mini Stat (inside balance card) ───────────────────────
  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 12),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Action Card ────────────────────────────────────────────
  Widget _actionCard(BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Goal Card ──────────────────────────────────────────────
  Widget _goalCard(String name, double progress, String amounts, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.flag_rounded, color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(amounts, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Transaction Tile ───────────────────────────────────────
  Widget _transactionTile(String title, String amount, bool isPositive, String date, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
                : [const Color(0xFFFF6584), const Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isPositive ? const Color(0xFF43E97B) : const Color(0xFFFF6584),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/saving_screens.dart';
import 'package:flutter_application_1/screens/StatementScreen.dart';
import 'package:flutter_application_1/screens/apply_loan_screen.dart';
import 'package:flutter_application_1/screens/loan_screen.dart';
import 'package:flutter_application_1/screens/withdraw_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFFD7E8BA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBrown,
        title: const Text("Umoja Finance", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // GREETING
            const Text(
              "Good Morning, Leticia 👋",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBrown),
            ),
            const SizedBox(height: 16),

            // BALANCE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Total Savings", style: TextStyle(fontSize: 16, color: primaryBrown)),
                  SizedBox(height: 8),
                  Text("UGX 2,450,000", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBrown)),
                  SizedBox(height: 4),
                  Text("As of Today", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // LOAN SUMMARY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Active Loan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text("UGX 1,200,000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  SizedBox(height: 4),
                  Text("Next due: 15 Feb 2026", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // QUICK ACTIONS
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _actionCard(context, Icons.savings, "Savings", primaryBrown, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsScreen()));
                }),
                _actionCard(context, Icons.request_page, "Apply Loan", Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ApplyLoanScreen()));
                }),
                _actionCard(context, Icons.payment, "Repay Loan", Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoansScreen()));
                }),
                _actionCard(context, Icons.account_balance_wallet, "Withdraw", Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawScreen()));
                }),
              ],
            ),
            const SizedBox(height: 25),

            // RECENT TRANSACTIONS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StatementsScreen()));
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // TRANSACTIONS LIST
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _transactionTile("Savings Deposit", "+ UGX 500,000", true),
                  _divider(),
                  _transactionTile("Loan Repayment", "- UGX 200,000", false),
                  _divider(),
                  _transactionTile("Withdraw Cash", "- UGX 100,000", false),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // QUICK ACTION CARD
  Widget _actionCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 3))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // TRANSACTION TILE
  Widget _transactionTile(String title, String amount, bool isPositive) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, color: isPositive ? Colors.green : Colors.red),
      title: Text(title),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red)),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Colors.grey);
}

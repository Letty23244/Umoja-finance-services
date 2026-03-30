import 'package:flutter/material.dart';
import '../widget/locked_savings_card.dart';
import '../widget/action_button.dart';

class LockedSavingsScreen extends StatelessWidget {
  const LockedSavingsScreen({super.key});

  // Dummy data
  static const List<Map<String, dynamic>> lockedSavings = [
    {
      'name': 'House Fund',
      'amount': '200,000',
      'lockedUntil': '2028-03-19',
      'interestRate': '5',
      'maturityAmount': '220,000',
      'status': 'active',
      'hasMatured': false,
    },
    {
      'name': 'School Fees',
      'amount': '500,000',
      'lockedUntil': '2026-01-01',
      'interestRate': '5',
      'maturityAmount': '525,000',
      'status': 'active',
      'hasMatured': true,
    },
    {
      'name': 'Business Capital',
      'amount': '1,000,000',
      'lockedUntil': '2030-03-19',
      'interestRate': '5',
      'maturityAmount': '1,250,000',
      'status': 'active',
      'hasMatured': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Savings'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.lock, color: Colors.white),
        label: const Text('Lock Savings', style: TextStyle(color: Colors.white)),
      ),
      body: lockedSavings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No locked savings yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Lock savings to earn interest over time', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  ActionButton(
                    label: 'Lock Savings',
                    icon: Icons.lock,
                    color: Colors.amber,
                    onPressed: () {},
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lockedSavings.length,
              itemBuilder: (context, index) {
                final saving = lockedSavings[index];
                return LockedSavingsCard(
                  name: saving['name'],
                  amount: saving['amount'],
                  lockedUntil: saving['lockedUntil'],
                  interestRate: saving['interestRate'],
                  maturityAmount: saving['maturityAmount'],
                  status: saving['status'],
                  hasMatured: saving['hasMatured'],
                  onWithdraw: saving['hasMatured'] ? () {} : null,
                );
              },
            ),
    );
  }
}
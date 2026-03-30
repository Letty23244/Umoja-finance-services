import 'package:flutter/material.dart';
import '../widget/auto_savings_card.dart';
import '../widget/action_button.dart';

class AutoSavingsScreen extends StatelessWidget {
  const AutoSavingsScreen({super.key});

  // Dummy data
  static const List<Map<String, dynamic>> autoSavings = [
    {
      'name': 'Weekly Business Savings',
      'amount': '50,000',
      'frequency': 'weekly',
      'paymentMethod': 'mobile_money',
      'nextDeductionDate': '2026-03-26',
      'status': 'active',
    },
    {
      'name': 'Monthly School Fees',
      'amount': '100,000',
      'frequency': 'monthly',
      'paymentMethod': 'bank_transfer',
      'nextDeductionDate': '2026-04-01',
      'status': 'paused',
    },
    {
      'name': 'Daily Coffee Savings',
      'amount': '5,000',
      'frequency': 'daily',
      'paymentMethod': 'mobile_money',
      'nextDeductionDate': '2026-03-20',
      'status': 'active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Savings'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Plan', style: TextStyle(color: Colors.white)),
      ),
      body: autoSavings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No Auto Savings Plans', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Set up automatic savings to grow your money', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  ActionButton(
                    label: 'Set Up Auto Savings',
                    icon: Icons.add,
                    color: Colors.amber,
                    onPressed: () {},
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: autoSavings.length,
              itemBuilder: (context, index) {
                final saving = autoSavings[index];
                return AutoSavingsCard(
                  name: saving['name'],
                  amount: saving['amount'],
                  frequency: saving['frequency'],
                  paymentMethod: saving['paymentMethod'],
                  nextDeductionDate: saving['nextDeductionDate'],
                  status: saving['status'],
                  onPause: saving['status'] == 'active' ? () {} : null,
                  onResume: saving['status'] == 'paused' ? () {} : null,
                  onCancel: saving['status'] != 'cancelled' ? () {} : null,
                );
              },
            ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widget/savings_goal_card.dart';
import '../widget/action_button.dart';

class SavingsGoalScreen extends StatelessWidget {
  const SavingsGoalScreen({super.key});

  // Dummy data
  static const List<Map<String, dynamic>> goals = [
    {
      'name': 'Buy Equipment',
      'targetAmount': '2000000',
      'currentAmount': '800000',
      'targetDate': '2026-12-01',
      'status': 'active',
    },
    {
      'name': 'Expand Stock',
      'targetAmount': '500000',
      'currentAmount': '500000',
      'targetDate': '2026-06-01',
      'status': 'completed',
    },
    {
      'name': 'Emergency Fund',
      'targetAmount': '1000000',
      'currentAmount': '250000',
      'targetDate': '2026-09-01',
      'status': 'active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Goal', style: TextStyle(color: Colors.white)),
      ),
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No savings goals yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Set a goal to track your savings progress', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  ActionButton(
                    label: 'Create Goal',
                    icon: Icons.flag,
                    color: Colors.amber,
                    onPressed: () {},
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return SavingsGoalCard(
                  name: goal['name'],
                  targetAmount: goal['targetAmount'],
                  currentAmount: goal['currentAmount'],
                  targetDate: goal['targetDate'],
                  status: goal['status'],
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            ),
    );
  }
}
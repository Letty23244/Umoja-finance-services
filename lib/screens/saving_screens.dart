import 'package:flutter/material.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  // Dummy data for transactions
  final List<Map<String, String>> transactions = const [
    {"date": "2026-02-01", "description": "Salary Deposit", "amount": "+\$1,200"},
    {"date": "2026-02-03", "description": "Groceries", "amount": "-\$150"},
    {"date": "2026-02-05", "description": "Electricity Bill", "amount": "-\$80"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$5,000",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Transactions List
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: Text(tx['description']!),
                      subtitle: Text(tx['date']!),
                      trailing: Text(
                        tx['amount']!,
                        style: TextStyle(
                          color: tx['amount']!.startsWith('-') ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add Savings clicked!")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

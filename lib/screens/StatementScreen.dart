import 'package:flutter/material.dart';

class StatementsScreen extends StatelessWidget {
  const StatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example list of statements
    final List<Map<String, String>> statements = [
      {
        "date": "2026-02-01",
        "description": "Loan payment",
        "amount": "- \$500"
      },
      {
        "date": "2026-01-28",
        "description": "Savings deposit",
        "amount": "+ \$200"
      },
      {
        "date": "2026-01-20",
        "description": "Loan disbursed",
        "amount": "+ \$1000"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statements"),
        backgroundColor: const Color(0xFF795548),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: statements.isEmpty
            ? const Center(
                child: Text(
                  "Your statements will appear here",
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.separated(
                itemCount: statements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final statement = statements[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      title: Text(
                        statement["description"]!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(statement["date"]!),
                      trailing: Text(
                        statement["amount"]!,
                        style: TextStyle(
                          fontSize: 16,
                          color: statement["amount"]!.startsWith("+")
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      backgroundColor: const Color(0xFFD7E8BA),
    );
  }
}

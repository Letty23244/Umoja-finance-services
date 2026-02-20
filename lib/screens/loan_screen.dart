import 'package:flutter/material.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example list of loans
    final List<Map<String, String>> loans = [
      {
        "type": "Personal Loan",
        "amount": "\$1,000",
        "status": "Approved",
        "date": "2026-01-15"
      },
      {
        "type": "Business Loan",
        "amount": "\$5,000",
        "status": "Pending",
        "date": "2026-02-05"
      },
      {
        "type": "Car Loan",
        "amount": "\$8,500",
        "status": "Rejected",
        "date": "2025-12-30"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loans"),
        backgroundColor: const Color(0xFF795548),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loans.isEmpty
            ? const Center(
                child: Text(
                  "Manage your loans here",
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.separated(
                itemCount: loans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  Color statusColor;
                  switch (loan["status"]) {
                    case "Approved":
                      statusColor = Colors.green;
                      break;
                    case "Pending":
                      statusColor = Colors.orange;
                      break;
                    case "Rejected":
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      title: Text(
                        loan["type"]!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Date: ${loan["date"]}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            loan["amount"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            loan["status"]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

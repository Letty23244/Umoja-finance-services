import 'package:flutter/material.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  static const Color primaryBrown = Color(0xFF795548);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        backgroundColor: primaryBrown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Current Balance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("UGX 2,450,000", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Withdrawal Procedures
            const Text(
              "Withdrawal Procedures",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "1. Enter the amount you want to withdraw.\n"
              "2. Select your preferred withdrawal method (Bank, Mobile Money, or Cash Pickup).\n"
              "3. Tap 'Withdraw' to complete the process.\n"
              "4. You will receive a confirmation once the transaction is successful.",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Amount Input
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.money),
              ),
            ),

            const SizedBox(height: 16),

            // Withdrawal Method Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Withdrawal Method",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: "Bank", child: Text("Bank Transfer")),
                DropdownMenuItem(value: "Mobile", child: Text("Mobile Money")),
                DropdownMenuItem(value: "Cash", child: Text("Cash Pickup")),
              ],
              onChanged: (value) {
                // Handle selection
              },
            ),

            const SizedBox(height: 20),

            // Withdraw Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: Add withdrawal logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Withdrawal request submitted!")),
                  );
                },
                child: const Text("Withdraw", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

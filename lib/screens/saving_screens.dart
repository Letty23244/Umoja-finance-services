import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/widget/balance_card.dart';
import 'package:flutter_application_1/widget/transaction_card.dart';
import 'package:flutter_application_1/widget/action_button.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color darkGreen = Color(0xFF4CAF50);
  static const Color bgColor = Color(0xFFF5F5F0);

  final String baseUrl = "https://umoja-financial-services-backend.onrender.com/api";

  bool isLoading = true;
  String? error;

  List<dynamic> transactions = [];

  String walletName = "My Savings Wallet";
  double balance = 0.0;
  double totalDeposit = 0.0;
  double totalWithdraw = 0.0;

  @override
  void initState() {
    super.initState();
    fetchWalletData();
  }

  double parseAmount(dynamic amount) {
    return double.tryParse(amount.toString().replaceAll(',', '')) ?? 0.0;
  }

  Future<void> fetchWalletData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/wallet/transactions"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data is List) ? data : (data["data"] ?? []);

        double dep = 0;
        double wit = 0;

        for (var t in list) {
          if (t["type"] == "deposit") {
            dep += parseAmount(t["amount"]);
          } else if (t["type"] == "withdraw") {
            wit += parseAmount(t["amount"]);
          }
        }

        setState(() {
          transactions = list;
          totalDeposit = dep;
          totalWithdraw = wit;
          balance = dep - wit;
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // No wallet yet — show empty state
        setState(() {
          transactions = [];
          totalDeposit = 0;
          totalWithdraw = 0;
          balance = 0;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load wallet data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deposit(double amount, String desc) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("$baseUrl/wallet/deposit"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "description": desc,
      }),
    ).timeout(const Duration(seconds: 60));

    fetchWalletData();
  }

  Future<void> withdraw(double amount, String desc) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("$baseUrl/wallet/withdraw"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "description": desc,
      }),
    ).timeout(const Duration(seconds: 60));

    fetchWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Savings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            error = null;
                          });
                          fetchWalletData();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BalanceCard(
                        walletName: walletName,
                        balance: balance.toStringAsFixed(0),
                        backgroundColor: primaryBrown,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _stat("Deposited", totalDeposit, Colors.green),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _stat("Withdrawn", totalWithdraw, Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              label: "Deposit",
                              icon: Icons.add,
                              color: darkGreen,
                              onPressed: () => showSheet("deposit"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ActionButton(
                              label: "Withdraw",
                              icon: Icons.remove,
                              color: Colors.red,
                              onPressed: () => showSheet("withdraw"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      transactions.isEmpty
                          ? const Center(
                              child: Text(
                                "No transactions yet.\nMake a deposit to get started!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, i) {
                                final tx = transactions[i];
                                return TransactionCard(
                                  type: tx["type"],
                                  description: tx["description"] ?? "",
                                  amount: tx["amount"].toString(),
                                  date: tx["created_at"] ?? "",
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _stat(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            "UGX ${value.toStringAsFixed(0)}",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void showSheet(String type) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amount = double.parse(amountController.text);
                  final desc = descController.text;
                  Navigator.pop(context);
                  if (type == "deposit") {
                    deposit(amount, desc);
                  } else {
                    withdraw(amount, desc);
                  }
                },
                child: Text(type == "deposit" ? "Deposit" : "Withdraw"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
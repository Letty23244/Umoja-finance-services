import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/widget/transaction_card.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color darkGreen = Color(0xFF4CAF50);
  static const Color bgColor = Color(0xFFF5F5F0);

  final String baseUrl = "http://127.0.0.1:8000/api";

  bool isLoading = true;
  String? error;

  List<dynamic> statements = [];

  @override
  void initState() {
    super.initState();
    fetchStatements();
  }

  // ── SAFE PARSE (IMPORTANT FIX) ─────────────────────────────
  double parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    return double.tryParse(amount.toString().replaceAll(',', '')) ?? 0.0;
  }

  // ── FETCH TRANSACTIONS ─────────────────────────────────────
  Future<void> fetchStatements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/wallet/transactions"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          statements = (data is List) ? data : (data["data"] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load statements (${response.statusCode})";
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

  // ── TOTALS ─────────────────────────────────────────────────
  double get totalDeposits {
    return statements
        .where((t) => t["type"] == "deposit")
        .fold(0.0, (sum, t) => sum + parseAmount(t["amount"]));
  }

  double get totalWithdrawals {
    return statements
        .where((t) => t["type"] == "withdraw")
        .fold(0.0, (sum, t) => sum + parseAmount(t["amount"]));
  }

  // ── UI ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Statements",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(child: Text(error!))

              : RefreshIndicator(
                  onRefresh: fetchStatements,
                  child: Column(
                    children: [

                      // ── SUMMARY ─────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: primaryBrown,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _summaryItem(
                              "Total In",
                              "UGX ${totalDeposits.toStringAsFixed(0)}",
                              Icons.arrow_downward,
                              darkGreen,
                            ),
                            _summaryItem(
                              "Total Out",
                              "UGX ${totalWithdrawals.toStringAsFixed(0)}",
                              Icons.arrow_upward,
                              Colors.red,
                            ),
                            _summaryItem(
                              "Records",
                              "${statements.length}",
                              Icons.receipt,
                              Colors.white,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── LIST ───────────────────────────────
                      Expanded(
                        child: statements.isEmpty
                            ? const Center(
                                child: Text("No transactions found"),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: statements.length,
                                itemBuilder: (context, index) {
                                  final tx = statements[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: TransactionCard(
                                      type: tx["type"] ?? "deposit",
                                      description: tx["description"] ?? "",
                                      amount: tx["amount"].toString(),
                                      date: tx["created_at"] ?? "",
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ── SUMMARY WIDGET ─────────────────────────────────────────
  Widget _summaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
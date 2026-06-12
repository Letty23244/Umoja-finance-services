import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../authScreens/auth_services_screen.dart';

class TransactionItem {
  final String title;
  final double amount;
  final bool isPositive;
  final String date;
  final IconData icon;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.isPositive,
    required this.date,
    required this.icon,
  });

  String get formattedAmount {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return isPositive ? '+ UGX $formatted' : '- UGX $formatted';
  }
}

class AccountProvider extends ChangeNotifier {
  double _walletBalance = 0.0;
  double _totalSavings = 0.0;
  double _lockedAmount = 0.0;
  bool _isLoading = false;
  List<TransactionItem> _transactions = [];

  double get walletBalance => _walletBalance;
  double get totalSavings => _totalSavings;
  double get lockedAmount => _lockedAmount;
  bool get isLoading => _isLoading;
  List<TransactionItem> get transactions => _transactions;

  String get formattedWallet => _format(_walletBalance);
  String get formattedTotal => _format(_totalSavings);
  String get formattedLocked => _format(_lockedAmount);

  String _format(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Future<void> fetchAccountData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      };

      // ── BALANCE: /api/wallet (SavingWalletController@index) ──
      // uses firstOrCreate — always returns 200, never 404
      final walletRes = await http.get(
        Uri.parse("${AuthService().baseUrl}/wallet"),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint("[wallet] Status: ${walletRes.statusCode}");
      debugPrint("[wallet] Body: ${walletRes.body}");

      if (walletRes.statusCode == 200) {
        final decoded = jsonDecode(walletRes.body);
        // { "status": "success", "data": { "balance": ..., ... } }
        final wallet = decoded['data'] ?? decoded;
        _walletBalance = double.tryParse(
              (wallet['balance'] ?? 0).toString(),
            ) ?? 0.0;
        _totalSavings = _walletBalance;
        _lockedAmount = double.tryParse(
              (wallet['locked_amount'] ?? 0).toString(),
            ) ?? 0.0;
      }

      // ── TRANSACTIONS: /api/wallet/transactions ──
      // FIXED: was hitting /api/transactions (wrong controller, no wallet data)
      final txRes = await http.get(
        Uri.parse("${AuthService().baseUrl}/wallet/transactions"),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint("[transactions] Status: ${txRes.statusCode}");
      debugPrint("[transactions] Body: ${txRes.body}");

      if (txRes.statusCode == 200) {
        final decoded = jsonDecode(txRes.body);

        List raw = [];
        if (decoded is Map<String, dynamic>) {
          raw = decoded['transactions'] ?? decoded['data'] ?? [];
        } else if (decoded is List) {
          raw = decoded;
        }

        _transactions = raw.take(10).map<TransactionItem>((t) {
          final type = (t['type'] ?? '').toString().toLowerCase();
          final isPositive = type == 'deposit' || type == 'credit';
          return TransactionItem(
            title: t['description'] ?? t['type'] ?? 'Transaction',
            amount: double.tryParse(
                  (t['amount'] ?? 0).toString(),
                ) ?? 0.0,
            isPositive: isPositive,
            date: _formatDate((t['created_at'] ?? '').toString()),
            icon: isPositive ? Icons.arrow_downward : Icons.arrow_upward,
          );
        }).toList();
      }
    } catch (e, stackTrace) {
      debugPrint("AccountProvider Error: $e");
      debugPrintStack(stackTrace: stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Called instantly after deposit succeeds ───────────────
  void applyDeposit(double newBalance, double amount, String method) {
    _walletBalance = newBalance;
    _totalSavings = newBalance;
    _transactions.insert(
      0,
      TransactionItem(
        title: 'Deposit ($method)',
        amount: amount,
        isPositive: true,
        date: 'Just now',
        icon: Icons.arrow_downward,
      ),
    );
    notifyListeners();
  }

  // ── Called instantly after withdrawal succeeds ────────────
  void applyWithdrawal(double newBalance, double amount, String method) {
    _walletBalance = newBalance;
    _totalSavings = newBalance;
    _transactions.insert(
      0,
      TransactionItem(
        title: 'Withdrawal ($method)',
        amount: amount,
        isPositive: false,
        date: 'Just now',
        icon: Icons.arrow_upward,
      ),
    );
    notifyListeners();
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'Today';
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return '${dt.day} ${_monthName(dt.month)}';
    } catch (_) {
      return raw;
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}
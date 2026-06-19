import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../authScreens/auth_services_screen.dart';

// ── Transaction model ──────────────────────────────────────
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

// ── Goal model ─────────────────────────────────────────────
class GoalItem {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final String status;

  GoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.status,
  });

  // 0.0 – 1.0 for LinearProgressIndicator
  double get progress => (progressPercentage / 100).clamp(0.0, 1.0);

  String get amountsLabel =>
      'UGX ${_fmt(currentAmount)} / ${_fmt(targetAmount)}'
      '${progressPercentage >= 100 ? ' ✓' : ''}';

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  factory GoalItem.fromJson(Map<String, dynamic> j) => GoalItem(
        id: j['id'] ?? 0,
        name: j['name'] ?? 'Goal',
        targetAmount: double.tryParse(
                (j['target_amount'] ?? 0).toString()) ?? 0,
        currentAmount: double.tryParse(
                (j['current_amount'] ?? 0).toString()) ?? 0,
        progressPercentage: double.tryParse(
                (j['progress_percentage'] ?? 0).toString()) ?? 0,
        status: j['status'] ?? 'active',
      );
}

// ── Provider ───────────────────────────────────────────────
class AccountProvider extends ChangeNotifier {
  double _walletBalance = 0.0;
  double _totalSavings  = 0.0;
  double _lockedAmount  = 0.0;
  bool   _isLoading     = false;

  List<TransactionItem> _transactions = [];
  List<GoalItem>        _goals        = [];

  double get walletBalance => _walletBalance;
  double get totalSavings  => _totalSavings;
  double get lockedAmount  => _lockedAmount;
  bool   get isLoading     => _isLoading;

  List<TransactionItem> get transactions => _transactions;
  List<GoalItem>        get goals        => _goals;

  // Only active goals for the home screen
  List<GoalItem> get activeGoals =>
      _goals.where((g) => g.status == 'active').toList();

  int get activeGoalsCount => activeGoals.length;

  String get formattedWallet => _format(_walletBalance);
  String get formattedTotal  => _format(_totalSavings);
  String get formattedLocked => _format(_lockedAmount);

  String _format(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

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

      // ── Run all 3 fetches in parallel ──────────────────
      final results = await Future.wait([
        http.get(Uri.parse("${AuthService().baseUrl}/wallet"),
            headers: headers).timeout(const Duration(seconds: 30)),
        http.get(Uri.parse("${AuthService().baseUrl}/wallet/transactions"),
            headers: headers).timeout(const Duration(seconds: 30)),
        http.get(Uri.parse("${AuthService().baseUrl}/savings-goals"),
            headers: headers).timeout(const Duration(seconds: 30)),
      ]);

      // ── Wallet balance ──────────────────────────────────
      final walletRes = results[0];
      debugPrint("[wallet] ${walletRes.statusCode}: ${walletRes.body}");
      if (walletRes.statusCode == 200) {
        final decoded = jsonDecode(walletRes.body);
        final wallet  = decoded['data'] ?? decoded;
        _walletBalance = double.tryParse(
                (wallet['balance'] ?? 0).toString()) ?? 0.0;
        _totalSavings  = _walletBalance;
        _lockedAmount  = double.tryParse(
                (wallet['locked_amount'] ?? 0).toString()) ?? 0.0;
      }

      // ── Transactions ────────────────────────────────────
      final txRes = results[1];
      debugPrint("[transactions] ${txRes.statusCode}");
      if (txRes.statusCode == 200) {
        final decoded = jsonDecode(txRes.body);
        List raw = decoded is List
            ? decoded
            : (decoded['transactions'] ?? decoded['data'] ?? []);
        _transactions = raw.take(10).map<TransactionItem>((t) {
          final type       = (t['type'] ?? '').toString().toLowerCase();
          final isPositive = type == 'deposit' || type == 'credit';
          return TransactionItem(
            title:      t['description'] ?? t['type'] ?? 'Transaction',
            amount:     double.tryParse(
                            (t['amount'] ?? 0).toString()) ?? 0.0,
            isPositive: isPositive,
            date:       _formatDate((t['created_at'] ?? '').toString()),
            icon: isPositive ? Icons.arrow_downward : Icons.arrow_upward,
          );
        }).toList();
      }

      // ── Savings goals (full data) ───────────────────────
      final goalsRes = results[2];
      debugPrint("[goals] ${goalsRes.statusCode}: ${goalsRes.body}");
      if (goalsRes.statusCode == 200) {
        try {
          final decoded = jsonDecode(goalsRes.body);
          List raw = [];
          if (decoded is List) {
            raw = decoded;
          } else if (decoded is Map) {
            final d = decoded['data'];
            final g = decoded['goals'];
            if (d is List) raw = d;
            else if (g is List) raw = g;
          }
          _goals = raw
              .map<GoalItem>((g) => GoalItem.fromJson(g as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint("[goals] parse error: $e");
          _goals = []; // ← always safe, never null
        }
      }
    } catch (e, st) {
      debugPrint("[account] fetch error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Instant update after deposit ───────────────────────────
  void applyDeposit(double newBalance, double amount, String method) {
    _walletBalance = newBalance;
    _totalSavings  = newBalance;
    _transactions.insert(0, TransactionItem(
      title: 'Deposit ($method)', amount: amount,
      isPositive: true, date: 'Just now', icon: Icons.arrow_downward,
    ));
    notifyListeners();
  }

  // ── Instant update after withdrawal ───────────────────────
  void applyWithdrawal(double newBalance, double amount, String method) {
    _walletBalance = newBalance;
    _totalSavings  = newBalance;
    _transactions.insert(0, TransactionItem(
      title: 'Withdrawal ($method)', amount: amount,
      isPositive: false, date: 'Just now', icon: Icons.arrow_upward,
    ));
    notifyListeners();
  }

  // ── Call after goal created/cancelled ─────────────────────
  void refreshGoals() => fetchAccountData();

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'Today';
    try {
      final dt   = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return '${dt.day} ${_monthName(dt.month)}';
    } catch (_) { return raw; }
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];
}
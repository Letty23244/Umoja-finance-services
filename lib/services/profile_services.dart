import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';

class ProfileService {
  static const String _baseUrl =
      'https://umoja-financial-services-backend.onrender.com/api';

  // ── mirrors AuthService._authHeaders() ──────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // same key as AuthService
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // ── Fetch profile from /api/me (same as AuthService.getCurrentUser) ──
  static Future<ProfileModel> fetchProfile() async {
    final token = (await SharedPreferences.getInstance()).getString('token');
    if (token == null) throw Exception('Not authenticated. Please log in again.');

    final response = await http
        .get(
          Uri.parse('$_baseUrl/me'),
          headers: await _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw Exception(
              'Request timed out. The server may be starting up — please try again.'),
        );

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load profile (${response.statusCode}).');
    }

    final data = jsonDecode(response.body);

    // /api/me returns { "user": {...} } based on AuthService usage
    final userJson = data is Map && data.containsKey('user')
        ? Map<String, dynamic>.from(data['user'])
        : Map<String, dynamic>.from(data);

    // Try to also get wallet stats in parallel — gracefully falls back
    Map<String, dynamic> walletData = {};
    try {
      walletData = await _fetchWalletStats();
    } catch (_) {}

    return ProfileModel.fromJson(userJson, stats: walletData);
  }

  // ── Fetch wallet balance + transaction count ─────────────
  // Uses /api/wallet/transactions (same endpoint as AuthService.getTransactions)
  static Future<Map<String, dynamic>> _fetchWalletStats() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/wallet/transactions'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);

    List<dynamic> txList = [];
    if (data is List) {
      txList = data;
    } else if (data['data'] is List) {
      txList = data['data'];
    } else if (data['transactions'] is List) {
      txList = data['transactions'];
    }

    // Calculate total savings from deposit transactions
    double totalSavings = 0;
    for (final tx in txList) {
      if (tx['type'] == 'deposit') {
        totalSavings += double.tryParse(tx['amount'].toString()) ?? 0;
      }
    }

    return {
      'transaction_count': txList.length,
      'total_savings': totalSavings,
    };
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth/user_model.dart';
import '../models/auth/auth_result.dart';

class AuthService {
  /// Backend Base URL
  final String baseUrl =
      "https://umoja-financial-services-backend.onrender.com/api";

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  /// Returns auth headers with Bearer token
  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  /// Returns plain JSON headers (no auth)
  Map<String, String> get _jsonHeaders => {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

  // ─────────────────────────────────────────────
  //  AUTH
  // ─────────────────────────────────────────────

  /// LOGIN
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      // Email not verified
      if (response.statusCode == 403 && data["action"] == "verify_email") {
        return AuthResult.unverified(data["message"]);
      }

      // Success
      if (response.statusCode == 200) {
        final token = data["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return AuthResult.success(
          token: token,
          user: UserModel.fromJson(data["user"]),
          message: data["message"],
        );
      }

      return AuthResult.failure(data["message"] ?? "Login failed");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// REGISTER
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: _jsonHeaders,
            body: jsonEncode({
              "name": name,
              "email": email,
              "phone": phone,
              "password": password,
              "password_confirmation": passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return AuthResult.success(
          token: token,
          user: UserModel.fromJson(data["user"]),
          message: data["message"],
        );
      }

      return AuthResult.failure(data["message"] ?? "Registration failed");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// FORGOT PASSWORD
  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/forgot-password"),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email}),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(message: data["message"]);
      }

      return AuthResult.failure(data["message"] ?? "Failed to send reset link");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// RESET PASSWORD
  Future<AuthResult> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/reset-password"),
            headers: _jsonHeaders,
            body: jsonEncode({
              "token": token,
              "email": email,
              "password": password,
              "password_confirmation": passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(message: data["message"]);
      }

      return AuthResult.failure(data["message"] ?? "Password reset failed");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  TOKEN & USER
  // ─────────────────────────────────────────────

  /// GET STORED TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// GET CURRENT USER
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http
          .get(
            Uri.parse("$baseUrl/me"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data["user"]);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await http
          .post(
            Uri.parse("$baseUrl/logout"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      // Ignore logout errors — always clear local token
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
    }
  }

  // ─────────────────────────────────────────────
  //  TRANSACTIONS
  // ─────────────────────────────────────────────

  /// GET ALL TRANSACTIONS
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated");

      final response = await http
          .get(
            Uri.parse("$baseUrl/wallet/transactions"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      print("[getTransactions] Status: ${response.statusCode}");
      print("[getTransactions] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data["data"] is List) {
          return List<Map<String, dynamic>>.from(data["data"]);
        } else if (data["transactions"] is List) {
          return List<Map<String, dynamic>>.from(data["transactions"]);
        }

        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? "Failed to fetch transactions");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// DEPOSIT
  /// ✅ FIXED: now hits /api/wallet/deposit (SavingWalletController@deposit)
  ///           which uses firstOrCreate — wallet is never missing
  Future<Map<String, dynamic>> deposit({
    required String amount,
    required String method,
    String? description,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated");

      final response = await http
          .post(
            Uri.parse("$baseUrl/wallet/deposit"), // ← FIXED (was /wallet/transactions/deposit)
            headers: await _authHeaders(),
            body: jsonEncode({
              "amount": amount,
              "method": method,
              "description": description ?? "",
            }),
          )
          .timeout(const Duration(seconds: 60));

      print("[deposit] Status: ${response.statusCode}");
      print("[deposit] Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data["message"] ?? "Deposit failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// WITHDRAW
  /// ✅ FIXED: now hits /api/wallet/withdraw (SavingWalletController@withdraw)
  ///           which uses firstOrCreate — wallet is never missing
  Future<Map<String, dynamic>> withdraw({
    required String amount,
    required String method,
    String? description,
    String? newBalance,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated");

      final response = await http
          .post(
            Uri.parse("$baseUrl/wallet/withdraw"), // ← FIXED (was /wallet/transactions/withdraw)
            headers: await _authHeaders(),
            body: jsonEncode({
              "amount": amount,
              "method": method,
              "description": description ?? "",
              if (newBalance != null) "new_balance": newBalance,
            }),
          )
          .timeout(const Duration(seconds: 60));

      print("[withdraw] Status: ${response.statusCode}");
      print("[withdraw] Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data["message"] ?? "Withdraw failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  SUPPORT TICKETS
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> sendSupportTicket({
    required String subject,
    required String message,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated");

      final response = await http
          .post(
            Uri.parse("$baseUrl/support-tickets"),
            headers: await _authHeaders(),
            body: jsonEncode({"subject": subject, "message": message}),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data["message"] ?? "Failed to send support ticket");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  NOTIFICATIONS
  // ─────────────────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/notifications"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception("Failed to load notifications");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/notifications/unread-count"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await http
          .put(
            Uri.parse("$baseUrl/notifications/$id/read"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await http
          .put(
            Uri.parse("$baseUrl/notifications/read-all"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await http
          .delete(
            Uri.parse("$baseUrl/notifications/$id"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  //  AUTO SAVINGS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAutoSavings() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/auto-savings"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      print("[getAutoSavings] Status: ${response.statusCode}");
      print("[getAutoSavings] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data['data'] is List) return List<Map<String, dynamic>>.from(data['data']);
        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load auto savings');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createAutoSaving({
    required String name,
    required String amount,
    required String frequency,
    required String paymentMethod,
    required int savingWalletId,
    required String paymentReference,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auto-savings"),
            headers: await _authHeaders(),
            body: jsonEncode({
              "name": name,
              "amount": amount,
              "frequency": frequency,
              "payment_method": paymentMethod,
              "saving_wallet_id": savingWalletId,
              "payment_reference":
                  "AUTO-${DateTime.now().millisecondsSinceEpoch}",
            }),
          )
          .timeout(const Duration(seconds: 60));

      print("[createAutoSaving] Status: ${response.statusCode}");
      print("[createAutoSaving] Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data['message'] ?? 'Failed to create auto saving');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> pauseAutoSaving(dynamic id) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/auto-savings/$id/pause"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Failed to pause plan');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> resumeAutoSaving(dynamic id) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/auto-savings/$id/resume"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Failed to resume plan');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteAutoSaving(dynamic id) async {
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/auto-savings/$id"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel plan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  LOCKED SAVINGS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLockedSavings() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/locked-savings"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      print("[getLockedSavings] Status: ${response.statusCode}");
      print("[getLockedSavings] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data['data'] is List) return List<Map<String, dynamic>>.from(data['data']);
        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load locked savings');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createLockedSaving({
    required String name,
    required String amount,
    required String durationMonths,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/locked-savings"),
            headers: await _authHeaders(),
            body: jsonEncode({
              "name": name,
              "amount": amount,
              "duration_months": durationMonths,
            }),
          )
          .timeout(const Duration(seconds: 60));

      print("[createLockedSaving] Status: ${response.statusCode}");
      print("[createLockedSaving] Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data['message'] ?? 'Failed to create locked saving');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> withdrawLockedSaving(dynamic id) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/locked-savings/$id/withdraw"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      print("[withdrawLockedSaving] Status: ${response.statusCode}");
      print("[withdrawLockedSaving] Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Withdrawal failed');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
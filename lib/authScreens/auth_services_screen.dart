import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth/user_model.dart';
import '../models/auth/auth_result.dart';

class AuthService {
  final String baseUrl =
      "https://umoja-financial-services-backend.onrender.com/api";

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  Map<String, String> get _jsonHeaders => {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // ─────────────────────────────────────────────
  //  AUTH
  // ─────────────────────────────────────────────

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
          .timeout(const Duration(seconds: 120));

      print('LOGIN status: ${response.statusCode}');
      print('LOGIN body:   ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 403 && data["action"] == "verify_email") {
        return AuthResult.unverified(data["message"]);
      }

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
      print('LOGIN error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final body = {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };

      print('REGISTER sending: ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      print('REGISTER status: ${response.statusCode}');
      print('REGISTER body:   ${response.body}');

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

      if (data["errors"] != null) {
        final errors = data["errors"] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return AuthResult.failure(firstError.first.toString());
        }
      }

      return AuthResult.failure(data["message"] ?? "Registration failed");
    } catch (e) {
      print('REGISTER error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/forgot-password"),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email}),
          )
          .timeout(const Duration(seconds: 120));

      print('FORGOT PASSWORD status: ${response.statusCode}');
      print('FORGOT PASSWORD body:   ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(message: data["message"]);
      }

      return AuthResult.failure(data["message"] ?? "Failed to send reset link");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

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
          .timeout(const Duration(seconds: 120));

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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http
          .get(Uri.parse("$baseUrl/me"), headers: await _authHeaders())
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data["user"]);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await http
          .post(Uri.parse("$baseUrl/logout"), headers: await _authHeaders())
          .timeout(const Duration(seconds: 120));
    } catch (_) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
    }
  }

  // ─────────────────────────────────────────────
  //  WALLET
  // ─────────────────────────────────────────────

  Future<int?> getWalletId() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/wallet"), headers: await _authHeaders())
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final wallet = data['data'] ?? data;
        return int.tryParse((wallet['id'] ?? 0).toString());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  PROFILE PHOTO
  // ─────────────────────────────────────────────

  Future<String> uploadProfilePhoto(File imageFile) async {
    final token = await getToken();
    if (token == null) throw Exception("User not authenticated");

    final request =
        http.MultipartRequest('POST', Uri.parse("$baseUrl/profile/photo"))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..files.add(
            await http.MultipartFile.fromPath('photo', imageFile.path),
          );

    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['photo_url'] as String;
    }

    final error = jsonDecode(response.body);
    throw Exception(
      error['message'] ?? 'Failed to upload photo (${response.statusCode}).',
    );
  }

  // ─────────────────────────────────────────────
  //  TRANSACTIONS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated");

      final response = await http
          .get(
            Uri.parse("$baseUrl/wallet/transactions"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data["data"] is List)
          return List<Map<String, dynamic>>.from(data["data"]);
        if (data["transactions"] is List)
          return List<Map<String, dynamic>>.from(data["transactions"]);
        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? "Failed to fetch transactions");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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
            Uri.parse("$baseUrl/wallet/deposit"),
            headers: await _authHeaders(),
            body: jsonEncode({
              "amount": amount,
              "method": method,
              "description": description ?? "",
            }),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data["message"] ?? "Deposit failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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
            Uri.parse("$baseUrl/wallet/withdraw"),
            headers: await _authHeaders(),
            body: jsonEncode({
              "amount": amount,
              "method": method,
              "description": description ?? "",
              if (newBalance != null) "new_balance": newBalance,
            }),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data["message"] ?? "Withdraw failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  SAVINGS GOALS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSavingsGoals() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/savings-goals"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));

      print('GOALS status: ${response.statusCode}');
      print('GOALS body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List)
          return List<Map<String, dynamic>>.from(data['data']);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load goals');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createSavingsGoal({
    required int savingsWalletId,
    required String name,
    required String targetAmount,
    String? targetDate,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/savings-goals"),
            headers: await _authHeaders(),
            body: jsonEncode({
              "savings_wallet_id": savingsWalletId,
              "name": name,
              "target_amount": targetAmount,
              if (targetDate != null && targetDate.isNotEmpty)
                "target_date": targetDate,
            }),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data['message'] ?? 'Failed to create goal');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateSavingsGoal(
    dynamic id, {
    String? name,
    String? targetAmount,
    String? targetDate,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (targetAmount != null) body['target_amount'] = targetAmount;
      if (targetDate != null && targetDate.isNotEmpty)
        body['target_date'] = targetDate;
      if (status != null) body['status'] = status;

      final response = await http
          .put(
            Uri.parse("$baseUrl/savings-goals/$id"),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Failed to update goal');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteSavingsGoal(dynamic id) async {
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/savings-goals/$id"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel goal');
      }
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
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
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
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) return jsonDecode(response.body);
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
          .timeout(const Duration(seconds: 120));

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
          .timeout(const Duration(seconds: 120));
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await http
          .put(
            Uri.parse("$baseUrl/notifications/read-all"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));
    } catch (_) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await http
          .delete(
            Uri.parse("$baseUrl/notifications/$id"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));
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
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List)
          return List<Map<String, dynamic>>.from(data['data']);
        if (data is List) return List<Map<String, dynamic>>.from(data);
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
          .timeout(const Duration(seconds: 120));

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
          .timeout(const Duration(seconds: 120));

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
          .timeout(const Duration(seconds: 120));

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
          .timeout(const Duration(seconds: 120));

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
          .timeout(const Duration(seconds: 120));

      print('LOCKED SAVINGS status: ${response.statusCode}');
      print('LOCKED SAVINGS body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Check 'data' key first
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load locked savings');
    } catch (e) {
      print('LOCKED SAVINGS error: $e');
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
          .timeout(const Duration(seconds: 120));

      print('CREATE LOCKED status: ${response.statusCode}');
      print('CREATE LOCKED body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) return data;
      throw Exception(data['message'] ?? 'Failed to create locked saving');
    } catch (e) {
      print('CREATE LOCKED error: $e');
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
          .timeout(const Duration(seconds: 120));

      print('WITHDRAW LOCKED status: ${response.statusCode}');
      print('WITHDRAW LOCKED body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Withdrawal failed');
    } catch (e) {
      print('WITHDRAW LOCKED error: $e');
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  //  SUPPORT TICKETS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTickets() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/support-tickets"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data['data'] is List)
          return List<Map<String, dynamic>>.from(data['data']);
        if (data['tickets'] is List)
          return List<Map<String, dynamic>>.from(data['tickets']);
        return [];
      }
      throw Exception("Failed to load tickets");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Temporary test
}

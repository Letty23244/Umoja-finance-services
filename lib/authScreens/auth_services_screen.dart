import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth/user_model.dart';
import '../models/auth/auth_result.dart';

class AuthService {
  /// Android Emulator URL
  final String baseUrl = "http://127.0.0.1:8000/api";

  /// ================= LOGIN =================
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      /// EMAIL NOT VERIFIED
      if (response.statusCode == 403 &&
          data["action"] == "resend_verification") {
        return AuthResult.unverified(data["message"]);
      }

      /// SUCCESS
      if (response.statusCode == 200) {
        final token = data["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        final user = UserModel.fromJson(data["user"]);

        return AuthResult.success(
          token: token,
          user: user,
          message: data["message"],
        );
      }

      return AuthResult.failure(data["message"] ?? "Login failed");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// ================= REGISTER =================
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
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

  /// ================= GET TOKEN =================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// ================= CURRENT USER =================
  Future<UserModel?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data["data"]);
    }

    return null;
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final token = await getToken();

    await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /// ================= WITHDRAW =================
Future<Map<String, dynamic>> withdraw({
  required String amount,
  required String method,
  String? description,
}) async {
  try {
    final token = await getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/withdraws"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "method": method,
        "description": description ?? "",
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    throw Exception(data["message"] ?? "Withdraw failed");
  } catch (e) {
    throw Exception(e.toString());
  }
}

// ======deposit=========
Future<Map<String, dynamic>> deposit({
  required String amount,
  required String method,
  String? description,
}) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse("$baseUrl/deposits"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "amount": amount,
      "method": method,
      "description": description ?? "",
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  }

  throw Exception(data["message"] ?? "Deposit failed");
}

 /// ================= TRANSACTIONS =================
  /// GET /api/wallet/transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final token = await getToken();
 
      if (token == null) throw Exception("User not authenticated");
 
      final response = await http.get(
        Uri.parse("$baseUrl/wallet/transactions"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
 
      final data = jsonDecode(response.body);
 
      if (response.statusCode == 200) {
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data["data"] is List) {
          return List<Map<String, dynamic>>.from(data["data"]);
        }
        return [];
      }
 
      throw Exception(data["message"] ?? "Failed to fetch transactions");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
 
  /// ================= TRANSACTION DEPOSIT =================
  /// POST /api/wallet/transactions/deposit
  Future<Map<String, dynamic>> transactionDeposit({
    required String amount,
    required String method,
    String? description,
  }) async {
    final token = await getToken();
 
    final response = await http.post(
      Uri.parse("$baseUrl/wallet/transactions/deposit"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "method": method,
        "description": description ?? "",
      }),
    );
 
    final data = jsonDecode(response.body);
 
    if (response.statusCode == 200 || response.statusCode == 201) return data;
 
    throw Exception(data["message"] ?? "Transaction deposit failed");
  }
 
  /// ================= TRANSACTION WITHDRAW =================
  /// POST /api/wallet/transactions/withdraw
  Future<Map<String, dynamic>> transactionWithdraw({
    required String amount,
    required String method,
    String? description,
  }) async {
    final token = await getToken();
 
    final response = await http.post(
      Uri.parse("$baseUrl/wallet/transactions/withdraw"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "method": method,
        "description": description ?? "",
      }),
    );
 
    final data = jsonDecode(response.body);
 
    if (response.statusCode == 200 || response.statusCode == 201) return data;
 
    throw Exception(data["message"] ?? "Transaction withdraw failed");
  }

  /// ================= FORGOT PASSWORD =================
  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(message: data["message"]);
      }

      return AuthResult.failure(data["message"]);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
  

  /// ================= RESET PASSWORD =================
  Future<AuthResult> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "token": token,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(message: data["message"]);
      }

      return AuthResult.failure(data["message"]);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// ================= SUPPORT TICKETS =================
/// POST /api/support-tickets
Future<Map<String, dynamic>> sendSupportTicket({
  required String subject,
  required String message,
}) async {
  try {
    final token = await getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/support-tickets"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "subject": subject,
        "message": message,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to send support ticket");
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<List<dynamic>> getNotifications() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/notifications"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("Failed to load notifications");
}

Future<int> getUnreadCount() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/notifications/unread-count"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['count'];
  }

  return 0;
}

Future<void> markNotificationRead(int id) async {
  final token = await getToken();

  await http.put(
    Uri.parse("$baseUrl/notifications/$id/read"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );
}

Future<void> markAllNotificationsRead() async {
  final token = await getToken();

  await http.put(
    Uri.parse("$baseUrl/notifications/read-all"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );
}

Future<void> deleteNotification(int id) async {
  final token = await getToken();

  await http.delete(
    Uri.parse("$baseUrl/notifications/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );
}
}
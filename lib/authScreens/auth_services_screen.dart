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
}
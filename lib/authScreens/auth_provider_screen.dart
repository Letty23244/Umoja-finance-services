import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';
import '../models/auth/user_model.dart';
import '../models/auth/auth_result.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  /// ================= STATE =================
  AuthStatus _status = AuthStatus.initial;

  UserModel? _user;
  String? _errorMessage;
  String? _successMessage;

  bool _emailVerified = false;
  bool _isUnverified = false;

  /// ================= GETTERS =================
  AuthStatus get status => _status;

  UserModel? get user => _user;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isUnverified => _isUnverified;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get emailVerified => _emailVerified;

  /// Convenience getters
  String? get userName => _user?.name;
  String? get userEmail => _user?.email;
  String? get userPhone => _user?.phone;
  String? get userRole => _user?.role;

  /// ================= INIT APP =================
  /// Call this in main.dart
  Future<void> init() async {
    _setLoading();

    final token = await _authService.getToken();

    if (token != null) {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser != null) {
        _user = currentUser;
        _emailVerified = currentUser.emailVerified;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// ================= LOGIN =================
  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    _isUnverified = false;

    final AuthResult result = await _authService.login(
      email: email,
      password: password,
    );

    /// SUCCESS
    if (result.isSuccess) {
      _user = result.user;
      _emailVerified = _user?.emailVerified ?? false;
      _status = AuthStatus.authenticated;

      _clearMessages();
      notifyListeners();
      return true;
    }

    /// EMAIL NOT VERIFIED
    if (result.isUnverified) {
      _isUnverified = true;
      _setError(result.errorMessage ?? "Email not verified");
      return false;
    }

    /// ERROR
    _setError(result.errorMessage ?? "Login failed");
    return false;
  }

  /// ================= REGISTER =================
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading();

    final AuthResult result = await _authService.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result.isSuccess) {
      _user = result.user;
      _emailVerified = false;
      _status = AuthStatus.authenticated;

      _successMessage = result.message;
      notifyListeners();
      return true;
    }

    _setError(result.errorMessage ?? "Registration failed");
    return false;
  }

  /// ================= FORGOT PASSWORD =================
  Future<bool> forgotPassword({required String email}) async {
    _setLoading();

    final result = await _authService.forgotPassword(email);

    if (result.isSuccess) {
      _successMessage = result.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    }

    _setError(result.errorMessage ?? "Failed to send reset link");
    return false;
  }

  /// ================= RESET PASSWORD =================
  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading();

    final result = await _authService.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result.isSuccess) {
      _successMessage = result.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    }

    _setError(result.errorMessage ?? "Password reset failed");
    return false;
  }

  /// ================= EMAIL VERIFIED CHECK =================
  Future<void> checkEmailVerified() async {
    final currentUser = await _authService.getCurrentUser();

    if (currentUser != null) {
      _user = currentUser;
      _emailVerified = currentUser.emailVerified;

      if (_emailVerified) {
        _isUnverified = false;
      }
    }

    notifyListeners();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _authService.logout();

    _user = null;
    _emailVerified = false;
    _isUnverified = false;

    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  /// ================= HELPERS =================
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

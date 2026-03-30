import 'user_model.dart';

class AuthResult {
  final bool isSuccess;
  final bool isUnverified;
  final String? token;
  final UserModel? user;
  final String? errorMessage;
  final String? message;

  AuthResult._({
    required this.isSuccess,
    this.isUnverified = false,
    this.token,
    this.user,
    this.errorMessage,
    this.message,
  });

  factory AuthResult.success({
    String? token,
    UserModel? user,
    String? message,
  }) {
    return AuthResult._(
      isSuccess: true,
      token: token,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: error,
    );
  }

  factory AuthResult.unverified(String message) {
    return AuthResult._(
      isSuccess: false,
      isUnverified: true,
      errorMessage: message,
    );
  }
}
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final bool emailVerified;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.emailVerified = false,
  });

  /// Convert JSON → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      emailVerified: json['email_verified'] == true ||
          json['email_verified_at'] != null,
    );
  }

  /// Convert UserModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'email_verified': emailVerified,
    };
  }
}
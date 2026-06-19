class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String accountNumber;
  final String location;
  final String memberSince;
  final bool isVerified;
  final String totalSavings;
  final int activeGoals;
  final int transactionCount;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.accountNumber,
    required this.location,
    required this.memberSince,
    required this.isVerified,
    this.totalSavings = 'UGX 0',
    this.activeGoals = 0,
    this.transactionCount = 0,
  });

  /// Maps your Laravel User model fields.
  /// Your /api/me returns { "user": { id, name, email, phone, created_at, email_verified_at, ... } }
  factory ProfileModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic> stats = const {},
  }) {
    String memberSince = 'N/A';
    if (json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at'].toString());
        const months = [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec'
        ];
        memberSince = '${months[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

    return ProfileModel(
      name:          json['name']?.toString()           ?? 'Unknown',
      email:         json['email']?.toString()          ?? '',
      // AuthService registers with "phone" field — match that
      phone:         json['phone']?.toString()
                  ?? json['phone_number']?.toString()   ?? 'N/A',
      accountNumber: json['account_number']?.toString() ?? 'N/A',
      location:      json['location']?.toString()
                  ?? json['address']?.toString()        ?? 'Kampala, Uganda',
      memberSince:   memberSince,
      isVerified:    json['email_verified_at'] != null,
      totalSavings:  _formatSavings(
                       stats['total_savings'] ?? json['total_savings']),
      activeGoals:   int.tryParse(
                       (stats['active_goals'] ?? json['active_goals'] ?? 0)
                           .toString()) ?? 0,
      transactionCount: int.tryParse(
                          (stats['transaction_count'] ??
                              json['transaction_count'] ?? 0)
                              .toString()) ?? 0,
    );
  }

  static String _formatSavings(dynamic raw) {
    if (raw == null) return 'UGX 0';
    final amount = double.tryParse(raw.toString()) ?? 0;
    if (amount >= 1000000) return 'UGX ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000)    return 'UGX ${(amount / 1000).toStringAsFixed(0)}K';
    return 'UGX ${amount.toStringAsFixed(0)}';
  }

  /// Avatar initials from real name
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
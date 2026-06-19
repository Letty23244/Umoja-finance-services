import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umoja_finance_services/providers/account_provider.dart';
import 'package:umoja_finance_services/models/profile_model.dart';
import 'package:umoja_finance_services/services/profile_services.dart';
import 'package:umoja_finance_services/screens/transaction_history_screen.dart';
import 'package:umoja_finance_services/screens/change_password_screen.dart';
import 'package:umoja_finance_services/screens/notification_screen.dart';
import 'package:umoja_finance_services/screens/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightBrown   = Color(0xFFA1887F);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  ProfileModel? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Also refresh wallet balance so profile stats are up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().fetchAccountData();
    });
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final profile = await ProfileService.fetchProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadProfile(),
      context.read<AccountProvider>().fetchAccountData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : _buildBody(),
    );
  }

  // ── Loading ────────────────────────────────────────────────
  Widget _buildLoader() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: primaryBrown),
        SizedBox(height: 16),
        Text('Loading profile…', style: TextStyle(color: primaryBrown, fontSize: 14)),
      ],
    ),
  );

  // ── Error ──────────────────────────────────────────────────
  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, color: lightBrown, size: 64),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: primaryBrown, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, color: lightGreen),
            label: const Text('Retry',
                style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  // ── Main Body ──────────────────────────────────────────────
  Widget _buildBody() {
    final p = _profile!;

    // ── Read live balance + tx count from AccountProvider ───
    final account = context.watch<AccountProvider>();
    final totalSavingsDisplay = account.isLoading
        ? '...'
        : 'UGX ${account.formattedTotal}';
    final txCount = account.transactions.length;

    return RefreshIndicator(
      color: primaryBrown,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [

            // ── Gradient Header ──────────────────────────────
            SizedBox(
              height: 280,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBrown, lightBrown, Color(0xFFBCAAA4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20, top: -20,
                          child: Container(
                            width: 150, height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 30, bottom: 10,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    )),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.edit_outlined,
                                      color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Floating Avatar Card ─────────────────
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBrown.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                        colors: [primaryBrown, lightBrown]),
                                  ),
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: const Color(0xFFEFEBE9),
                                      child: Text(
                                        p.initials,
                                        style: const TextStyle(
                                          color: primaryBrown,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        color: primaryBrown, size: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBrown,
                                      )),
                                  const SizedBox(height: 2),
                                  Text(p.email,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  if (p.isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: lightGreen,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified,
                                              color: primaryBrown, size: 12),
                                          SizedBox(width: 4),
                                          Text('Verified',
                                              style: TextStyle(
                                                color: primaryBrown,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Row — balance live from AccountProvider ─
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    _statItem('Total Savings', totalSavingsDisplay,
                        Icons.savings_outlined),
                    _divider(),
                    _statItem('Active Goals', '${p.activeGoals}',
                        Icons.flag_outlined),
                    _divider(),
                    _statItem('Transactions', '$txCount',
                        Icons.receipt_long_outlined),
                    _divider(),
                    _statItem('Member', p.memberSince,
                        Icons.calendar_today_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Account Info ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Account Info'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200, blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoTile(Icons.phone_outlined, 'Phone Number', p.phone),
                        _dividerLine(),
                        _infoTile(Icons.credit_card_outlined, 'Account Number',
                            p.accountNumber),
                        _dividerLine(),
                        _infoTile(Icons.account_balance_wallet_outlined,
                            'Wallet Balance',
                            account.isLoading
                                ? 'Loading…'
                                : 'UGX ${account.formattedWallet}'),
                        _dividerLine(),
                        _infoTile(Icons.location_on_outlined, 'Location',
                            p.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Settings ──────────────────────────────
                  _sectionTitle('Settings'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200, blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      children: [
                        _settingsTile(context, Icons.lock_outline,
                            'Change Password', 'Update your password',
                            () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => ChangePasswordScreen()))),
                        _dividerLine(),
                        _settingsTile(context, Icons.notifications_outlined,
                            'Notifications', 'Manage alerts',
                            () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => NotificationScreen()))),
                        _dividerLine(),
                        _settingsTile(context, Icons.receipt_long_outlined,
                            'Transaction History', 'View all',
                            () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        TransactionHistoryScreen()))),
                        _dividerLine(),
                        _settingsTile(context, Icons.help_outline,
                            'Help & Support', 'Get assistance',
                            () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => HelpSupportScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Logout ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: lightGreen, size: 20),
                      label: const Text('Logout',
                          style: TextStyle(
                              color: lightGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Row(
    children: [
      Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              color: primaryBrown, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: primaryBrown)),
    ],
  );

  Widget _statItem(String label, String value, IconData icon) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: primaryBrown, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: primaryBrown),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

  Widget _dividerLine() =>
      Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100);

  Widget _infoTile(IconData icon, String title, String value) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: lightGreen, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: primaryBrown, size: 18),
    ),
    title: Text(title,
        style: const TextStyle(fontSize: 11, color: Colors.grey)),
    subtitle: Text(value,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryBrown)),
  );

  Widget _settingsTile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) =>
      ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: lightGreen, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: primaryBrown, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: primaryBrown)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(
                color: primaryBrown, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout',
                style: TextStyle(color: lightGreen)),
          ),
        ],
      ),
    );
  }
}
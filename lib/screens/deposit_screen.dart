import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen>
    with SingleTickerProviderStateMixin {
  // ── Theme ──────────────────────────────────────────────────
  static const Color primaryBrown = Color(0xFF795548);
  static const Color darkBrown    = Color(0xFF4E342E);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color accentGreen  = Color(0xFF8BC34A);
  static const Color bgColor      = Color(0xFFF5F5F0);
  static const Color cardWhite    = Color(0xFFFFFFFF);
  static const Color mutedText    = Color(0xFF9E9E9E);

  // ── State ──────────────────────────────────────────────────
  final _formKey          = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController   = TextEditingController();
  String? _selectedMethod;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Deposit Logic ──────────────────────────────────────────
  Future<void> _deposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      _showSnack("Select a deposit method", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService().deposit(
        amount: _amountController.text,
        method: _selectedMethod!,
        description: _descController.text,
      );

      setState(() => _isLoading = false);

      if (response["status"] == "success" ||
          response["message"] != null) {
        _showSuccessSheet();
        _amountController.clear();
        _descController.clear();
        setState(() => _selectedMethod = null);
      } else {
        _showSnack(response["message"] ?? "Deposit failed", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack("Network error. Please try again.", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            backgroundColor: darkBrown,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBackground(),
            ),
          ),

          // ── Body ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Balance Pill ─────────────────────
                        _buildBalancePill(),
                        const SizedBox(height: 28),

                        // ── Amount Card ──────────────────────
                        _sectionLabel('Amount to Deposit', Icons.monetization_on_outlined),
                        const SizedBox(height: 10),
                        _buildAmountCard(),
                        const SizedBox(height: 28),

                        // ── Method Selection ─────────────────
                        _sectionLabel('Deposit Method', Icons.swap_horiz_rounded),
                        const SizedBox(height: 14),
                        _buildMethodRow(),
                        const SizedBox(height: 28),

                        // ── Description ──────────────────────
                        _sectionLabel('Note (Optional)', Icons.edit_note_rounded),
                        const SizedBox(height: 10),
                        _buildDescriptionCard(),
                        const SizedBox(height: 24),

                        // ── Info Banner ──────────────────────
                        _buildInfoBanner(),
                        const SizedBox(height: 32),

                        // ── Submit Button ─────────────────────
                        _buildSubmitButton(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar Background ─────────────────────────────────────
  Widget _buildAppBarBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: darkBrown.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 60, left: 20,
            child: Opacity(
              opacity: 0.06,
              child: Wrap(
                spacing: 18, runSpacing: 18,
                children: List.generate(20, (_) => Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28, top: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 11),
                      SizedBox(width: 6),
                      Text(
                        'FUNDS DEPOSIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Deposit\nFunds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Balance Pill ───────────────────────────────────────────
  Widget _buildBalancePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B5E20), const Color(0xFF388E3C).withOpacity(0.85)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: TextStyle(
                  color: lightGreen.withOpacity(0.7),
                  fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'UGX 1,250,000',
                style: TextStyle(
                  color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800, letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Amount Card ────────────────────────────────────────────
  Widget _buildAmountCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withOpacity(0.1),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'UGX',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: darkBrown, letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Ugandan Shilling',
                    style: TextStyle(fontSize: 11, color: mutedText, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded, color: darkBrown, size: 16),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 34, fontWeight: FontWeight.w800,
              color: darkBrown, letterSpacing: -1,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: Colors.grey.shade200, fontSize: 34,
                fontWeight: FontWeight.w800, letterSpacing: -1,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: ['50,000', '100,000', '200,000', '500,000']
                  .map((amt) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _amountController.text = amt.replaceAll(',', '')),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              amt,
                              style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600, color: primaryBrown,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Method Row ─────────────────────────────────────────────
  Widget _buildMethodRow() {
    return Row(
      children: [
        _methodTile('Mobile\nMoney',  Icons.phone_android_rounded,   'Mobile'),
        const SizedBox(width: 12),
        _methodTile('Bank\nTransfer', Icons.account_balance_rounded, 'Bank'),
        const SizedBox(width: 12),
        _methodTile('Cash\nDeposit',  Icons.storefront_outlined,     'Cash'),
      ],
    );
  }

  // ── Description Card ───────────────────────────────────────
  Widget _buildDescriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextFormField(
        controller: _descController,
        maxLines: 3,
        style: const TextStyle(fontSize: 14, color: darkBrown, height: 1.5),
        decoration: InputDecoration(
          hintText: 'e.g. Savings top-up, business funds...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Icon(Icons.edit_note_rounded, color: primaryBrown.withOpacity(0.4), size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  // ── Info Banner ────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightGreen.withOpacity(0.45), lightGreen.withOpacity(0.12)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentGreen.withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_outlined, color: darkBrown, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Instant Processing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: darkBrown)),
                SizedBox(height: 3),
                Text(
                  'Your deposit is secured and reflected in your account instantly.',
                  style: TextStyle(fontSize: 11, color: primaryBrown, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.45),
            blurRadius: 24, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: _isLoading ? null : _deposit,
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: lightGreen, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded, size: 15, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Deposit Funds',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white.withOpacity(0.6)),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: primaryBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: primaryBrown),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: darkBrown, letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Method Tile ────────────────────────────────────────────
  Widget _methodTile(String label, IconData icon, String value) {
    final isSelected = _selectedMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(colors: [cardWhite, cardWhite]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF1B5E20).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.06),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : lightGreen.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22,
                    color: isSelected ? Colors.white : primaryBrown),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : darkBrown,
                  height: 1.3, letterSpacing: 0.2,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  width: 18, height: 3,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Success Sheet ──────────────────────────────────────────
  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightGreen.withOpacity(0.2),
                  ),
                ),
                Container(
                  width: 76, height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentGreen.withOpacity(0.6), lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.check_rounded, color: darkBrown, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Deposit Successful!',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: darkBrown, letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'UGX ${_amountController.text} via $_selectedMethod\nhas been added to your account.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: mutedText, height: 1.7),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withOpacity(0.35),
                    blurRadius: 18, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 15, letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
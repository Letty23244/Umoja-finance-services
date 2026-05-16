import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
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
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadTransactions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Fetch from /api/wallet/transactions ────────────────────
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService().getTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  String _str(Map tx, String key, [String fallback = '']) =>
      tx[key]?.toString() ?? fallback;

  bool _isCredit(Map tx) {
    if (tx['is_credit'] != null) return tx['is_credit'] == true;
    final type = _str(tx, 'type').toLowerCase();
    return type == 'deposit';
  }

  IconData _iconFor(Map tx) {
    switch (_str(tx, 'type').toLowerCase()) {
      case 'deposit':    return Icons.arrow_downward_rounded;
      case 'withdrawal': return Icons.arrow_upward_rounded;
      case 'saving':     return Icons.savings_outlined;
      default:           return Icons.receipt_long_outlined;
    }
  }

  String _fmtAmount(Map tx) {
    final raw = tx['amount']?.toString().replaceAll(',', '') ?? '0';
    return _fmt((double.tryParse(raw) ?? 0).toInt());
  }

  String _groupLabel(String date) {
    final parts = date.trim().split(' ');
    return parts.length >= 3 ? '${parts[1]} ${parts[2]}' : date;
  }

  List<Map<String, dynamic>> get _filtered {
    switch (_selectedFilter) {
      case 'Deposits':
        return _transactions.where((t) => _str(t, 'type').toLowerCase() == 'deposit').toList();
      case 'Withdrawals':
        return _transactions.where((t) => _str(t, 'type').toLowerCase() == 'withdrawal').toList();
      case 'Savings':
        return _transactions.where((t) => _str(t, 'type').toLowerCase() == 'saving').toList();
      default:
        return _transactions;
    }
  }

  double get _totalIn => _transactions
      .where((t) => _isCredit(t))
      .fold(0.0, (s, t) => s + (double.tryParse(t['amount']?.toString().replaceAll(',', '') ?? '0') ?? 0));

  double get _totalOut => _transactions
      .where((t) => !_isCredit(t))
      .fold(0.0, (s, t) => s + (double.tryParse(t['amount']?.toString().replaceAll(',', '') ?? '0') ?? 0));

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final transactions = _filtered;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [

          // ── Sliver App Bar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            elevation: 0,
            backgroundColor: darkBrown,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadTransactions,
                tooltip: 'Refresh',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBackground(),
            ),
          ),

          // ── Loading ────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(child: _LoadingState())

          // ── Error ──────────────────────────────────────────
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _ErrorState(message: _errorMessage!, onRetry: _loadTransactions),
            )

          // ── Content ────────────────────────────────────────
          else ...[
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      _buildCountRow(transactions),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            if (transactions.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = transactions[index];
                      final date    = _str(tx, 'date', _str(tx, 'created_at'));
                      final prevDate = index == 0
                          ? ''
                          : _str(transactions[index - 1], 'date',
                              _str(transactions[index - 1], 'created_at'));
                      final showHeader =
                          index == 0 || _groupLabel(date) != _groupLabel(prevDate);

                      return FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) _buildMonthHeader(_groupLabel(date)),
                            _buildTransactionTile(tx),
                          ],
                        ),
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── App Bar Background ─────────────────────────────────────
  Widget _buildAppBarBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E2723), darkBrown, primaryBrown],
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
            bottom: 60, left: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentGreen.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 65, left: 20,
            child: Opacity(
              opacity: 0.06,
              child: Wrap(
                spacing: 18, runSpacing: 18,
                children: List.generate(20, (_) => Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: lightGreen.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_long_outlined, color: lightGreen, size: 11),
                      SizedBox(width: 6),
                      Text('TRANSACTION HISTORY',
                          style: TextStyle(
                              color: lightGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your\nActivity',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 16),
                if (!_isLoading && _errorMessage == null)
                  Row(
                    children: [
                      _summaryCard('Total In',  'UGX ${_fmt(_totalIn.toInt())}',
                          Icons.arrow_downward_rounded, accentGreen),
                      const SizedBox(width: 10),
                      _summaryCard('Total Out', 'UGX ${_fmt(_totalOut.toInt())}',
                          Icons.arrow_upward_rounded, Colors.redAccent.shade100),
                      const SizedBox(width: 10),
                      _summaryCard('Records',   '${_transactions.length} items',
                          Icons.receipt_long_rounded, lightGreen),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ───────────────────────────────────────────
  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────────
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Deposits', 'Withdrawals', 'Savings'].map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF3E2723), darkBrown],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(colors: [cardWhite, cardWhite]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? darkBrown.withOpacity(0.25)
                            : Colors.grey.withOpacity(0.06),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? lightGreen : mutedText,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Count Row ──────────────────────────────────────────────
  Widget _buildCountRow(List transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    size: 12, color: primaryBrown),
              ),
              const SizedBox(width: 6),
              Text(
                '${transactions.length} ${_selectedFilter == 'All' ? 'transactions' : _selectedFilter.toLowerCase()}',
                style: const TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          Text(_selectedFilter,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Month Header ───────────────────────────────────────────
  Widget _buildMonthHeader(String month) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: primaryBrown.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(month,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primaryBrown,
                  fontSize: 12,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ── Transaction Tile ───────────────────────────────────────
  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final credit = _isCredit(tx);
    final color  = credit ? const Color(0xFF388E3C) : Colors.redAccent.shade200;
    final bgTint = credit
        ? accentGreen.withOpacity(0.08)
        : Colors.red.withOpacity(0.05);
    final date = _str(tx, 'date', _str(tx, 'created_at'));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryBrown.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Icon(_iconFor(tx), color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _str(tx, 'title',
                        _str(tx, 'description', 'Transaction')),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: darkBrown),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 10, color: mutedText),
                      const SizedBox(width: 4),
                      Text(date,
                          style: TextStyle(
                              fontSize: 11,
                              color: mutedText,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${credit ? '+' : '-'} UGX ${_fmtAmount(tx)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: color),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    credit ? 'Credit' : 'Debit',
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: lightGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 40, color: primaryBrown.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          Text('No ${_selectedFilter.toLowerCase()} found',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Try a different filter',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

// ── Loading State ──────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: Color(0xFF795548), strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading transactions...',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Error State ────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 36, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4E342E))),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E2723), Color(0xFF4E342E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF4E342E).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Color(0xFFD7E8BA),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
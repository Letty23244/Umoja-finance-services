import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

// ── Theme constants ────────────────────────────────────────
const Color _amber      = Color(0xFFFFA000);
const Color _amberDark  = Color(0xFFE65100);
const Color _amberLight = Color(0xFFFFF8E1);
const Color _bgColor    = Color(0xFFFAFAF7);
const Color _cardWhite  = Color(0xFFFFFFFF);
const Color _darkText   = Color(0xFF33200A);
const Color _mutedText  = Color(0xFF9E9E9E);

class LockedSavingsScreen extends StatefulWidget {
  const LockedSavingsScreen({super.key});

  @override
  State<LockedSavingsScreen> createState() => _LockedSavingsScreenState();
}

class _LockedSavingsScreenState extends State<LockedSavingsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _savings = [];
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
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animController, curve: Curves.easeOut));
    _loadSavings();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSavings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // ← debug
      final token = await AuthService().getToken();
      print('TOKEN USED: $token');

      final data = await AuthService().getLockedSavings();
      print('SAVINGS COUNT: ${data.length}');
      print('SAVINGS DATA: $data');

      setState(() {
        _savings = data;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      print('LOAD ERROR: $e');
      setState(() {
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _withdrawSaving(dynamic id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Early Withdrawal?',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: _darkText)),
        content: Text(
            'Withdraw from "$name"? Early withdrawal may incur penalties.',
            style: const TextStyle(color: _mutedText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AuthService().withdrawLockedSaving(id);
        _showSnack('Withdrawal successful', Colors.green);
        _loadSavings();
      } catch (e) {
        _showSnack(
            e.toString().replaceFirst('Exception: ', ''),
            Colors.red);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showNewLockSheet() {
    final nameCtrl     = TextEditingController();
    final amountCtrl   = TextEditingController();
    final durationCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding:
                const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _amberLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: _amber, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text('Lock New Savings',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _darkText)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Locked savings earn more — funds are held until maturity.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 20),
                  _sheetField(
                      nameCtrl,
                      'Savings Name (e.g. Land Fund)',
                      Icons.label_outline),
                  const SizedBox(height: 14),
                  _sheetField(amountCtrl, 'Amount (UGX)',
                      Icons.attach_money,
                      isNumber: true),
                  const SizedBox(height: 14),
                  _sheetField(
                      durationCtrl,
                      'Lock Duration (months)',
                      Icons.lock_clock_outlined,
                      isNumber: true),
                  const SizedBox(height: 6),
                  Text(
                    'e.g. 3 = locked for 3 months',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _amber,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (nameCtrl.text.isEmpty ||
                                  amountCtrl.text.isEmpty ||
                                  durationCtrl.text.isEmpty) {
                                _showSnack(
                                    'Please fill all fields',
                                    Colors.red);
                                return;
                              }
                              setModal(
                                  () => isSaving = true);
                              try {
                                await AuthService()
                                    .createLockedSaving(
                                  name: nameCtrl.text,
                                  amount: amountCtrl.text,
                                  durationMonths:
                                      durationCtrl.text,
                                );
                                if (ctx.mounted)
                                  Navigator.pop(ctx);
                                _showSnack('Savings locked!',
                                    Colors.green);
                                _loadSavings();
                              } catch (e) {
                                setModal(
                                    () => isSaving = false);
                                _showSnack(
                                    e.toString().replaceFirst(
                                        'Exception: ', ''),
                                    Colors.red);
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : const Text('Lock Savings',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: _amber, size: 20),
        filled: true,
        fillColor: _amberLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }

  double get _totalLocked => _savings.fold(
      0.0,
      (s, e) =>
          s +
          (double.tryParse(e['amount']
                      ?.toString()
                      .replaceAll(',', '') ??
                  '0') ??
              0));

  int get _maturedCount => _savings
      .where((s) => s['status']?.toString() == 'matured')
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            elevation: 0,
            backgroundColor: _amberDark,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadSavings,
                tooltip: 'Refresh',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBg(),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: _LoadingState())
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _ErrorState(
                  message: _errorMessage!,
                  onRetry: _loadSavings),
            )
          else if (_savings.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 20, 20, 8),
                    child: Text(
                      '${_savings.length} locked saving${_savings.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _darkText),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final saving = _savings[index];
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: _LockedSavingsTile(
                        saving: saving,
                        onWithdraw: () => _withdrawSaving(
                            saving['id'],
                            saving['name']?.toString() ??
                                'Savings'),
                      ),
                    );
                  },
                  childCount: _savings.length,
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewLockSheet,
        backgroundColor: _amber,
        icon: const Icon(Icons.lock_rounded,
            color: Colors.white),
        label: const Text('Lock Savings',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildAppBarBg() {
    final totalFormatted = _totalLocked
        .toInt()
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8D3900), _amberDark, _amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 24, right: 24, bottom: 24, top: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          color: Colors.white, size: 11),
                      SizedBox(width: 6),
                      Text('LOCKED SAVINGS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Locked\nSavings Vault',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.5)),
                const SizedBox(height: 16),
                if (!_isLoading && _errorMessage == null)
                  Row(
                    children: [
                      _summaryCard(
                          'Total Locked',
                          'UGX $totalFormatted',
                          Icons.lock_rounded,
                          Colors.amberAccent.shade100),
                      const SizedBox(width: 10),
                      _summaryCard(
                          'Matured',
                          '$_maturedCount ready',
                          Icons.lock_open_rounded,
                          Colors.greenAccent.shade200),
                      const SizedBox(width: 10),
                      _summaryCard(
                          'Total',
                          '${_savings.length} vaults',
                          Icons.savings_rounded,
                          Colors.white70),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.white.withOpacity(0.12)),
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
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
                color: _amberLight, shape: BoxShape.circle),
            child: Icon(Icons.lock_outline_rounded,
                size: 40, color: _amber.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          const Text('No locked savings yet',
              style: TextStyle(
                  fontSize: 15,
                  color: _darkText,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Tap Lock Savings to create a vault',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ── Individual Locked Savings Tile ─────────────────────────
class _LockedSavingsTile extends StatelessWidget {
  final Map<String, dynamic> saving;
  final VoidCallback onWithdraw;

  const _LockedSavingsTile(
      {required this.saving, required this.onWithdraw});

  String _str(String key, [String fallback = '']) =>
      saving[key]?.toString() ?? fallback;

  String _fmt(String raw) {
    final n = int.tryParse(raw.replaceAll(',', '')) ?? 0;
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},');
  }

  Color get _statusColor {
    switch (_str('status')) {
      case 'active':
        return _amber;
      case 'matured':
        return Colors.green;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (_str('status')) {
      case 'active':
        return Icons.lock_rounded;
      case 'matured':
        return Icons.lock_open_rounded;
      case 'withdrawn':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  double _progress() {
    try {
      final start  = DateTime.parse(_str('created_at'));
      final months = int.tryParse(_str('duration_months', '1')) ?? 1;
      final end    = DateTime(
          start.year, start.month + months, start.day);
      final now    = DateTime.now();
      if (now.isAfter(end)) return 1.0;
      final total   = end.difference(start).inDays;
      final elapsed = now.difference(start).inDays;
      return (elapsed / total).clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status    = _str('status', 'active');
    final amount    = _fmt(_str('amount', '0'));
    final name      = _str('name', 'Locked Savings');
    final duration  = _str('duration_months', '—');
    final maturesOn =
        _str('maturity_date', _str('matures_at', '—'));
    final progress  = _progress();
    final pct       = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: _amber.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_statusIcon,
                      color: _statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: _darkText)),
                      const SizedBox(height: 3),
                      Text(
                        'UGX $amount · $duration month${duration == '1' ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lock progress',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600)),
                Text('$pct%',
                    style: TextStyle(
                        fontSize: 11,
                        color: _statusColor,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor:
                    AlwaysStoppedAnimation(_statusColor),
              ),
            ),
            const SizedBox(height: 12),
            if (maturesOn != '—')
              _chip(Icons.event_available_rounded,
                  'Matures: $maturesOn', Colors.teal),
            const Divider(
                height: 20, color: Color(0xFFF0F0F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status != 'withdrawn')
                  GestureDetector(
                    onTap: onWithdraw,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'matured'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'matured'
                                ? Icons.lock_open_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            color: status == 'matured'
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status == 'matured'
                                ? 'Withdraw'
                                : 'Early Withdraw',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: status == 'matured'
                                    ? Colors.green
                                    : Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
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
              color: _amber, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading savings...',
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
  const _ErrorState(
      {required this.message, required this.onRetry});

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
                    color: _darkText)),
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
                  color: _amber,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white,
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
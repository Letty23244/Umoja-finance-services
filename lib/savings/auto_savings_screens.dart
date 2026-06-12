import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

// ── Theme constants ────────────────────────────────────────
const Color _amber = Color(0xFFFFA000);
const Color _amberDark = Color(0xFFE65100);
const Color _amberLight = Color(0xFFFFF8E1);
const Color _bgColor = Color(0xFFFAFAF7);
const Color _cardWhite = Color(0xFFFFFFFF);
const Color _darkText = Color(0xFF33200A);
const Color _mutedText = Color(0xFF9E9E9E);

class AutoSavingsScreen extends StatefulWidget {
  const AutoSavingsScreen({super.key});

  @override
  State<AutoSavingsScreen> createState() => _AutoSavingsScreenState();
}

class _AutoSavingsScreenState extends State<AutoSavingsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _plans = [];
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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadPlans();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await AuthService().getAutoSavings();
      setState(() {
        _plans = data;
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

  Future<void> _pausePlan(dynamic id) async {
    try {
      await AuthService().pauseAutoSaving(id);
      _showSnack('Plan paused', Colors.orange);
      _loadPlans();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  Future<void> _resumePlan(dynamic id) async {
    try {
      await AuthService().resumeAutoSaving(id);
      _showSnack('Plan resumed', Colors.green);
      _loadPlans();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  Future<void> _cancelPlan(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Plan?',
          style: TextStyle(fontWeight: FontWeight.w800, color: _darkText),
        ),
        content: const Text(
          'This will permanently cancel your auto savings plan.',
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it', style: TextStyle(color: _mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel Plan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await AuthService().deleteAutoSaving(id);
        _showSnack('Plan cancelled', Colors.red);
        _loadPlans();
      } catch (e) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showNewPlanSheet() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String frequency = 'weekly';
    String paymentMethod = 'mobile_money';
    String? selectedWalletId;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const Text(
                'New Auto Savings Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 20),

              // Plan Name
              _sheetField(
                nameCtrl,
                'Plan Name (e.g. School Fees)',
                Icons.label_outline,
              ),
              const SizedBox(height: 14),

              // Amount
              _sheetField(
                amountCtrl,
                'Amount (UGX)',
                Icons.attach_money,
                isNumber: true,
              ),
              const SizedBox(height: 14),

              // Frequency
              const Text(
                'Frequency',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['daily', 'weekly', 'monthly'].map((f) {
                  final selected = frequency == f;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => frequency = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? _amber : _amberLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? _amber : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            f[0].toUpperCase() + f.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: selected ? Colors.white : _amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Payment Method
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children:
                    [
                      {'value': 'mobile_money', 'label': 'Mobile Money'},
                      {'value': 'bank_transfer', 'label': 'Bank Transfer'},
                    ].map((m) {
                      final selected = paymentMethod == m['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setModal(() => paymentMethod = m['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? _amber : _amberLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? _amber : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                m['label']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: selected ? Colors.white : _amber,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty ||
                              amountCtrl.text.isEmpty) {
                            _showSnack('Please fill all fields', Colors.red);
                            return;
                          }
                          setModal(() => isSaving = true);
                          try {
                            await AuthService().createAutoSaving(
                              name: nameCtrl.text,
                              amount: amountCtrl.text,
                              frequency: frequency,
                              paymentMethod: paymentMethod,
                              savingWalletId: selectedWalletId == null
                                  ? 0
                                  : (int.tryParse(selectedWalletId) ?? 0),
                              paymentReference:
                                  "AUTO-${DateTime.now().millisecondsSinceEpoch}",
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnack('Plan created!', Colors.green);
                            _loadPlans();
                          } catch (e) {
                            setModal(() => isSaving = false);
                            _showSnack(
                              e.toString().replaceFirst('Exception: ', ''),
                              Colors.red,
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: _amber, size: 20),
        filled: true,
        fillColor: _amberLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlans = _plans.where((p) => p['status'] == 'active').length;
    final pausedPlans = _plans.where((p) => p['status'] == 'paused').length;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ───────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            backgroundColor: _amberDark,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadPlans,
                tooltip: 'Refresh',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBg(activePlans, pausedPlans),
            ),
          ),

          // ── Loading ──────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(child: _LoadingState())
          // ── Error ────────────────────────────────────────
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _ErrorState(message: _errorMessage!, onRetry: _loadPlans),
            )
          // ── Empty ────────────────────────────────────────
          else if (_plans.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          // ── List ─────────────────────────────────────────
          else ...[
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      '${_plans.length} plan${_plans.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _darkText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final plan = _plans[index];
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: _AutoSavingsTile(
                      plan: plan,
                      onPause: plan['status'] == 'active'
                          ? () => _pausePlan(plan['id'])
                          : null,
                      onResume: plan['status'] == 'paused'
                          ? () => _resumePlan(plan['id'])
                          : null,
                      onCancel: plan['status'] != 'cancelled'
                          ? () => _cancelPlan(plan['id'])
                          : null,
                    ),
                  );
                }, childCount: _plans.length),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPlanSheet,
        backgroundColor: _amber,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildAppBarBg(int active, int paused) {
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
              left: 24,
              right: 24,
              bottom: 24,
              top: 70,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'AUTO SAVINGS',
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
                const SizedBox(height: 12),
                const Text(
                  'Automatic\nSavings Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isLoading && _errorMessage == null)
                  Row(
                    children: [
                      _summaryCard(
                        'Active',
                        '$active plans',
                        Icons.play_circle_outline,
                        Colors.greenAccent.shade200,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        'Paused',
                        '$paused plans',
                        Icons.pause_circle_outline,
                        Colors.orangeAccent.shade100,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        'Total',
                        '${_plans.length} plans',
                        Icons.list_alt_rounded,
                        Colors.white70,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
            decoration: BoxDecoration(
              color: _amberLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.autorenew_rounded,
              size: 40,
              color: _amber.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No auto savings plans yet',
            style: TextStyle(
              fontSize: 15,
              color: _darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + New Plan to get started',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── Individual Plan Tile ───────────────────────────────────
class _AutoSavingsTile extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const _AutoSavingsTile({
    required this.plan,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  String _str(String key, [String fallback = '']) =>
      plan[key]?.toString() ?? fallback;

  Color get _statusColor {
    switch (_str('status')) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _freqIcon {
    switch (_str('frequency')) {
      case 'daily':
        return Icons.today_rounded;
      case 'weekly':
        return Icons.view_week_rounded;
      case 'monthly':
        return Icons.calendar_month_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _fmt(String raw) {
    final n = int.tryParse(raw.replaceAll(',', '')) ?? 0;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _str('status');
    final amount = _fmt(_str('amount', '0'));
    final frequency = _str('frequency', 'weekly');
    final method = _str(
      'payment_method',
      _str('paymentMethod', ''),
    ).replaceAll('_', ' ');
    final nextDate = _str(
      'next_deduction_date',
      _str('nextDeductionDate', '—'),
    );

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _amberLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_freqIcon, color: _amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _str('name', 'Auto Savings Plan'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'UGX $amount · ${frequency[0].toUpperCase()}${frequency.substring(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Info row ─────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (method.isNotEmpty)
                  _chip(
                    Icons.phone_android_rounded,
                    method.toUpperCase(),
                    Colors.purple,
                  ),
                _chip(Icons.event_rounded, 'Next: $nextDate', Colors.teal),
              ],
            ),

            const Divider(height: 20, color: Color(0xFFF0F0F0)),

            // ── Actions ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'active' && onPause != null)
                  _actionBtn(
                    'Pause',
                    Icons.pause_rounded,
                    Colors.orange,
                    onPause!,
                  ),
                if (status == 'paused' && onResume != null)
                  _actionBtn(
                    'Resume',
                    Icons.play_arrow_rounded,
                    Colors.green,
                    onResume!,
                  ),
                if (status != 'cancelled' && onCancel != null) ...[
                  const SizedBox(width: 8),
                  _actionBtn(
                    'Cancel',
                    Icons.cancel_outlined,
                    Colors.red,
                    onCancel!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
          const CircularProgressIndicator(color: _amber, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Loading plans...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
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
              child: Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _amber,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umoja_finance_services/authScreens/auth_services_screen.dart';
import 'package:umoja_finance_services/providers/account_provider.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightBrown   = Color(0xFFA1887F);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  final _auth = AuthService();

  List<Map<String, dynamic>> _goals = [];
  int? _walletId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _auth.getWalletId(),
        _auth.getSavingsGoals(),
      ]);
      if (mounted) {
        setState(() {
          _walletId = results[0] as int?;
          _goals    = results[1] as List<Map<String, dynamic>>;
        });
      }
    } catch (e) {
      if (mounted) setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Notify AccountProvider so home screen updates instantly ─
  void _syncHomeScreen() {
    if (mounted) {
      context.read<AccountProvider>().fetchAccountData();
    }
  }

  Future<void> _createGoal(Map<String, dynamic> body) async {
    try {
      await _auth.createSavingsGoal(
        savingsWalletId: _walletId!,
        name:            body['name'],
        targetAmount:    body['target_amount'],
        targetDate:      body['target_date'],
      );
      _showSnack('Goal created!', success: true);
      _loadAll();
      _syncHomeScreen(); // ← update home screen active goals count
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''),
          success: false);
    }
  }

  Future<void> _updateGoal(dynamic id, Map<String, dynamic> body) async {
    try {
      await _auth.updateSavingsGoal(
        id,
        name:         body['name'],
        targetAmount: body['target_amount'],
        targetDate:   body['target_date'],
        status:       body['status'],
      );
      _showSnack('Goal updated!', success: true);
      _loadAll();
      _syncHomeScreen(); // ← update home screen active goals count
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''),
          success: false);
    }
  }

  Future<void> _deleteGoal(dynamic id) async {
    try {
      await _auth.deleteSavingsGoal(id);
      _showSnack('Goal cancelled.', success: true);
      _loadAll();
      _syncHomeScreen(); // ← update home screen active goals count
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''),
          success: false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showGoalSheet({Map<String, dynamic>? goal}) {
    if (_walletId == null) {
      _showSnack('Wallet not found. Please make a deposit first.',
          success: false);
      return;
    }

    final isEdit     = goal != null;
    final nameCtrl   = TextEditingController(
        text: isEdit ? goal['name'] ?? '' : '');
    final targetCtrl = TextEditingController(
        text: isEdit ? (goal['target_amount'] ?? '').toString() : '');
    final dateCtrl   = TextEditingController(
        text: isEdit ? (goal['target_date'] ?? '') : '');
    final formKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24, right: 24, top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(isEdit ? 'Edit Goal' : 'New Savings Goal',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown)),
              const SizedBox(height: 20),
              _field(nameCtrl, 'Goal Name', Icons.flag_outlined,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Enter a goal name' : null),
              const SizedBox(height: 14),
              _field(targetCtrl, 'Target Amount (UGX)',
                  Icons.savings_outlined,
                  keyboard: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter target amount';
                    if (double.tryParse(v) == null) return 'Enter a valid number';
                    if (double.parse(v) < 1) return 'Amount must be at least 1';
                    return null;
                  }),
              const SizedBox(height: 14),
              TextFormField(
                controller: dateCtrl,
                readOnly: true,
                decoration: _deco('Target Date (optional)',
                    Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2035),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: primaryBrown)),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    dateCtrl.text =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(context);
                    final body = {
                      'name':          nameCtrl.text.trim(),
                      'target_amount': targetCtrl.text.trim(),
                      if (dateCtrl.text.isNotEmpty)
                        'target_date': dateCtrl.text.trim(),
                    };
                    if (isEdit) {
                      _updateGoal(goal['id'], body);
                    } else {
                      _createGoal(body);
                    }
                  },
                  child: Text(isEdit ? 'Update Goal' : 'Create Goal',
                      style: const TextStyle(
                          color: lightGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Goal',
            style: TextStyle(
                color: primaryBrown, fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to cancel "${goal['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteGoal(goal['id']);
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Savings Goals',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalSheet(),
        backgroundColor: primaryBrown,
        icon: const Icon(Icons.add, color: lightGreen),
        label: const Text('New Goal',
            style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : _goals.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: primaryBrown,
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _goalCard(_goals[i]),
      ),
    );
  }

  Widget _goalCard(Map<String, dynamic> goal) {
    final target      = double.tryParse(
            (goal['target_amount'] ?? '0').toString()) ?? 0;
    final current     = double.tryParse(
            (goal['current_amount'] ?? '0').toString()) ?? 0;
    final progress    = target > 0
        ? (current / target).clamp(0.0, 1.0)
        : 0.0;
    final percent     = (progress * 100).toInt();
    final status      = (goal['status'] ?? 'active').toString();
    final isCancelled = status == 'cancelled';
    final isCompleted = status == 'completed' || percent >= 100;

    final color = isCompleted
        ? const Color(0xFF43E97B)
        : isCancelled
            ? Colors.grey
            : percent >= 50
                ? const Color(0xFFFF9F43)
                : primaryBrown;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4))
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.flag_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal['name'] ?? 'Unnamed Goal',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryBrown)),
                      if ((goal['target_date'] ?? '').toString().isNotEmpty)
                        Text('By ${_formatDate(goal['target_date'])}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    isCompleted ? '✓ Done' : isCancelled ? 'Cancelled' : 'Active',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('UGX ${_fmt(current)} / ${_fmt(target)}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                Text('$percent%',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn('Edit', Icons.edit_outlined,
                      lightGreen, primaryBrown,
                      () => _showGoalSheet(goal: goal)),
                  const SizedBox(width: 8),
                  _actionBtn('Cancel', Icons.close,
                      Colors.red.shade50, Colors.red,
                      () => _confirmDelete(goal)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const mo = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${mo[dt.month]} ${dt.year}';
    } catch (_) { return raw; }
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBrown, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F5F0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBrown, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
      );

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      decoration: _deco(label, icon),
    );
  }

  Widget _buildLoader() => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: primaryBrown),
          SizedBox(height: 16),
          Text('Loading goals…',
              style: TextStyle(color: primaryBrown, fontSize: 14)),
        ]));

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.cloud_off_outlined, color: lightBrown, size: 64),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: primaryBrown)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh, color: lightGreen),
              label: const Text('Retry',
                  style: TextStyle(
                      color: lightGreen, fontWeight: FontWeight.bold)),
            ),
          ]),
        ));

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: lightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.flag_outlined,
                  color: primaryBrown, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('No savings goals yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown)),
            const SizedBox(height: 8),
            const Text('Tap "New Goal" to start tracking\nyour savings progress',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ));
}
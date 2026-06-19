import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);
  static const Color darkBrown    = Color(0xFF4E342E);

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  // ── Fetch support tickets from backend ─────────────────────
  Future<void> _fetchTickets() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await AuthService().getTickets();
      setState(() {
        _tickets = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Submit new support ticket ──────────────────────────────
  void _showReportDialog() {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          bool isSending = false;
          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Report a Problem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: darkBrown)),
                const SizedBox(height: 4),
                Text('Our team will respond as soon as possible.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 20),

                // Subject
                TextField(
                  controller: subjectCtrl,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.subject_rounded, color: primaryBrown, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),

                // Message
                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue in detail...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: isSending
                        ? null
                        : () async {
                            if (subjectCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill subject and message')),
                              );
                              return;
                            }
                            setModal(() => isSending = true);
                            try {
                              await AuthService().sendSupportTicket(
                                subject: subjectCtrl.text.trim(),
                                message: messageCtrl.text.trim(),
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Support request sent ✅'), backgroundColor: Colors.green),
                              );
                              _fetchTickets(); // refresh list
                            } catch (e) {
                              setModal(() => isSending = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                              );
                            }
                          },
                    child: isSending
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Umoja Finance', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
        content: const Text('Umoja Finance helps women save, plan goals and grow money securely.\n\nVersion 1.0.0'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: primaryBrown)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchTickets,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryBrown,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(children: const [
                Icon(Icons.support_agent, color: lightGreen, size: 40),
                SizedBox(height: 12),
                Text('How can we help you?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('We\'re here to assist you anytime', style: TextStyle(color: Colors.white70)),
              ]),
            ),

            const SizedBox(height: 24),

            // ── Quick actions ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                _helpTile(Icons.report_problem_outlined, 'Report a Problem', 'Let us know what\'s wrong', Colors.red, _showReportDialog),
                _helpTile(Icons.info_outline, 'About Umoja Finance', 'App version 1.0.0', Colors.blue, _showAboutDialog),
              ]),
            ),

            const SizedBox(height: 24),

            // ── My Tickets section ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Support Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkBrown)),
                  if (_isLoading)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primaryBrown)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                  child: Row(children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                    TextButton(onPressed: _fetchTickets, child: const Text('Retry', style: TextStyle(color: primaryBrown))),
                  ]),
                ),
              )
            else if (!_isLoading && _tickets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)]),
                  child: Column(children: [
                    Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No tickets yet', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Tap "Report a Problem" to submit one', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tickets.length,
                itemBuilder: (_, i) => _ticketCard(_tickets[i]),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportDialog,
        backgroundColor: primaryBrown,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Help tile ──────────────────────────────────────────────
  Widget _helpTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: primaryBrown),
        onTap: onTap,
      ),
    );
  }

  // ── Ticket card ────────────────────────────────────────────
  Widget _ticketCard(Map<String, dynamic> ticket) {
    final status  = (ticket['status'] ?? 'open').toString().toLowerCase();
    final subject = ticket['subject']?.toString() ?? 'Support Ticket';
    final message = ticket['message']?.toString() ?? '';
    final date    = _formatDate(ticket['created_at']?.toString() ?? '');

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'resolved':
        statusColor = Colors.green;
        statusIcon  = Icons.check_circle_outline_rounded;
        break;
      case 'closed':
        statusColor = Colors.grey;
        statusIcon  = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon  = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: darkBrown))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, size: 12, color: statusColor),
              const SizedBox(width: 4),
              Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
            ]),
          ),
        ]),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(message, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt   = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _monthName(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}
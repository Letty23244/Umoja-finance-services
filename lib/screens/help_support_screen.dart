import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Header Banner ──────────────────────────────
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.support_agent, color: lightGreen, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We\'re here to assist you anytime',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Contact ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _contactCard(
                      context,
                      Icons.email_outlined,
                      'Email Us',
                      'support@umoja.com',
                      Colors.blue,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening email...')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _contactCard(
                      context,
                      Icons.phone_outlined,
                      'Call Us',
                      '+256 700 000 000',
                      Colors.green,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling support...')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Help Options ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Support Options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBrown),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _helpTile(
                          context,
                          Icons.help_outline,
                          'Frequently Asked Questions',
                          'Find quick answers to common questions',
                          Colors.orange,
                          () => _showFAQ(context),
                        ),
                        Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100),
                        _helpTile(
                          context,
                          Icons.report_problem_outlined,
                          'Report a Problem',
                          'Let us know what\'s wrong',
                          Colors.red,
                          () => _showReportDialog(context),
                        ),
                        Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100),
                        _helpTile(
                          context,
                          Icons.chat_outlined,
                          'Live Chat',
                          'Chat with our support team',
                          Colors.purple,
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Live chat coming soon!')),
                          ),
                        ),
                        Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100),
                        _helpTile(
                          context,
                          Icons.info_outline,
                          'About Umoja Finance',
                          'App version 1.0.0',
                          Colors.blue,
                          () => _showAboutDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── FAQ Section ──────────────────────────
                  const Text(
                    'Popular Questions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBrown),
                  ),
                  const SizedBox(height: 12),

                  _faqCard('How do I deposit money?', 'Go to Savings → tap Deposit → enter amount and description.'),
                  _faqCard('How do I lock my savings?', 'Go to Lock Savings → enter amount and choose duration (1-5 years).'),
                  _faqCard('How does auto savings work?', 'Set up a plan with an amount and frequency. We deduct automatically.'),
                  _faqCard('How do I withdraw locked savings?', 'You can only withdraw after the lock period ends (maturity date).'),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Card ───────────────────────────────────────────
  Widget _contactCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Help Tile ──────────────────────────────────────────────
  Widget _helpTile(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: primaryBrown)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.arrow_forward_ios, size: 12, color: primaryBrown),
      ),
      onTap: onTap,
    );
  }

  // ── FAQ Card ───────────────────────────────────────────────
  Widget _faqCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.question_mark, color: primaryBrown, size: 16),
        ),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryBrown)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ── Show FAQ ───────────────────────────────────────────────
  void _showFAQ(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('See Popular Questions below!')),
    );
  }

  // ── Report Dialog ──────────────────────────────────────────
  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Report a Problem', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the issue you\'re experiencing:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your issue here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBrown),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. We\'ll get back to you!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Submit', style: TextStyle(color: lightGreen)),
          ),
        ],
      ),
    );
  }

  // ── About Dialog ───────────────────────────────────────────
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.savings, color: primaryBrown, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Umoja Finance', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 12),
            Text(
              'Umoja Finance is a digital savings platform designed to help women manage their savings, set goals, and grow their money securely.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: lightGreen)),
          ),
        ],
      ),
    );
  }
}
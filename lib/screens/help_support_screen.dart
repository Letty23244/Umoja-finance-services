import 'package:flutter/material.dart';
  import '../authScreens/auth_services_screen.dart';// ⭐ IMPORT

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFFD7E8BA);
  static const Color bgColor = Color(0xFFF5F5F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
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
                children: const [
                  Icon(Icons.support_agent, color: lightGreen, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'We\'re here to assist you anytime',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// SUPPORT OPTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _helpTile(
                    context,
                    Icons.report_problem_outlined,
                    'Report a Problem',
                    'Let us know what\'s wrong',
                    Colors.red,
                    () => _showReportDialog(context),
                  ),
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
          ],
        ),
      ),
    );
  }

  /// HELP TILE
  Widget _helpTile(BuildContext context, IconData icon,
      String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  /// ⭐⭐⭐ REPORT PROBLEM (CONNECTED TO API)
  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Report a Problem',
                style: TextStyle(
                    color: primaryBrown, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Describe the issue:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your issue here...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),

                /// ⭐ SUBMIT BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final message = controller.text.trim();

                          if (message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please describe the problem")),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            await authService.sendSupportTicket(
                              subject: "User Support Request",
                              message: message,
                            );

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Support request sent successfully ✅"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() => isLoading = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Failed to send request: $e"),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(color: lightGreen),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ABOUT
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Umoja Finance'),
        content: const Text(
            'Umoja Finance helps women save, plan goals and grow money securely.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
  }
}
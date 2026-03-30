import 'package:flutter/material.dart';

class AutoSavingsCard extends StatelessWidget {
  final String name;
  final String amount;
  final String frequency;
  final String paymentMethod;
  final String nextDeductionDate;
  final String status;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const AutoSavingsCard({
    super.key,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.paymentMethod,
    required this.nextDeductionDate,
    required this.status,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  Color get _statusColor {
    switch (status) {
      case 'active':    return Colors.green;
      case 'paused':    return Colors.orange;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData get _frequencyIcon {
    switch (frequency) {
      case 'daily':   return Icons.today;
      case 'weekly':  return Icons.view_week;
      case 'monthly': return Icons.calendar_month;
      default:        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_frequencyIcon, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(Icons.attach_money, 'UGX $amount', Colors.green),
                _buildChip(_frequencyIcon, frequency.toUpperCase(), Colors.blue),
                _buildChip(
                  Icons.phone_android,
                  paymentMethod.replaceAll('_', ' ').toUpperCase(),
                  Colors.purple,
                ),
                _buildChip(Icons.calendar_today, 'Next: $nextDeductionDate', Colors.orange),
              ],
            ),

            const Divider(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'active' && onPause != null)
                  TextButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause, color: Colors.orange, size: 18),
                    label: const Text('Pause', style: TextStyle(color: Colors.orange)),
                  ),
                if (status == 'paused' && onResume != null)
                  TextButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow, color: Colors.green, size: 18),
                    label: const Text('Resume', style: TextStyle(color: Colors.green)),
                  ),
                if (status != 'cancelled' && onCancel != null)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                    label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
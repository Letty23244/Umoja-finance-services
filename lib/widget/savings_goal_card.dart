import 'package:flutter/material.dart';

class SavingsGoalCard extends StatelessWidget {
  final String name;
  final String targetAmount;
  final String currentAmount;
  final String targetDate;
  final String status;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SavingsGoalCard({
    super.key,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    this.onEdit,
    this.onDelete,
  });

  double get _progress {
    final target = double.tryParse(targetAmount) ?? 1;
    final current = double.tryParse(currentAmount) ?? 0;
    return (current / target).clamp(0.0, 1.0);
  }

  Color get _statusColor {
    switch (status) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.amber;
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
                    const Icon(Icons.flag, color: Colors.amber),
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

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progress >= 1.0 ? Colors.green : Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UGX $currentAmount saved',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
                Text(
                  'UGX $targetAmount goal',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Progress percentage and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_progress * 100).toStringAsFixed(1)}% complete',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Target: $targetDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // Action buttons
            if (onEdit != null || onDelete != null) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                      label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
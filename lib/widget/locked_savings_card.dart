import 'package:flutter/material.dart';

class LockedSavingsCard extends StatelessWidget {
  final String name;
  final String amount;
  final String lockedUntil;
  final String interestRate;
  final String maturityAmount;
  final String status;
  final bool hasMatured;
  final VoidCallback? onWithdraw;

  const LockedSavingsCard({
    super.key,
    required this.name,
    required this.amount,
    required this.lockedUntil,
    required this.interestRate,
    required this.maturityAmount,
    required this.status,
    required this.hasMatured,
    this.onWithdraw,
  });

  Color get _statusColor {
    switch (status) {
      case 'matured':   return Colors.green;
      case 'withdrawn': return Colors.grey;
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
                    const Icon(Icons.lock, color: Colors.amber),
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

            // Amount info
            Row(
              children: [
                _buildInfoItem('Locked Amount', 'UGX $amount', Colors.blue),
                const SizedBox(width: 16),
                _buildInfoItem('Interest Rate', '$interestRate%', Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem('Matures On', lockedUntil, Colors.orange),
                const SizedBox(width: 16),
                _buildInfoItem('At Maturity', 'UGX $maturityAmount', Colors.purple),
              ],
            ),

            // Matured banner
            if (hasMatured) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Savings matured! Ready to withdraw.',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            // Withdraw button
            if (hasMatured && onWithdraw != null && status == 'active') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  label: const Text('Withdraw', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
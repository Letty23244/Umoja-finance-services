import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String type;
  final String description;
  final String amount;
  final String date;

  const TransactionCard({
    super.key,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
  });

  bool get isDeposit => type == 'deposit' || type == 'saving';

  Color get _color => isDeposit ? Colors.green : Colors.red;

  IconData get _icon => isDeposit ? Icons.arrow_downward : Icons.arrow_upward;

  String get _typeLabel {
    switch (type) {
      case 'deposit':       return 'Deposit';
      case 'withdrawal':    return 'Withdrawal';
      case 'saving':        return 'Saving';
      case 'locked_saving': return 'Locked Saving';
      case 'auto_saving':   return 'Auto Saving';
      default:              return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.1),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(
          description.isNotEmpty ? description : _typeLabel,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(date),
        trailing: Text(
          '${isDeposit ? '+' : '-'} UGX $amount',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
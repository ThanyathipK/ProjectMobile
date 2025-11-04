import 'package:flutter/material.dart';
import 'package:se/theme.dart';

class TransactionListItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final IconData icon;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen)
                  .withOpacity(0.1),
          child: Icon(
            icon,
            color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(category, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Text(
          "${isExpense ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}",
          style: TextStyle(
            color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Navigate to Edit Transaction Screen
        },
      ),
    );
  }
}
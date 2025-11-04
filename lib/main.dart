import 'dart:io'; // Keep for Platform.isAndroid check
import 'package:flutter/material.dart';
// Note: We REMOVED 'package:flutter/services.dart' as it's no longer needed

import 'package:intl/intl.dart';
import 'package:se/models/transaction.dart' as tx_model;
import 'package:se/screens/splash_screen.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

Future<void> main() async {
  // 1. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize the database
  await DatabaseHelper.instance.database;

  // 3. Process any due recurring transactions
  await _processRecurringTransactions();
  
  // 4. Run the app
  runApp(const SmartExpenseApp());
}

// Processes recurring transactions on app start
Future<void> _processRecurringTransactions() async {
  final dbHelper = DatabaseHelper.instance;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  // Get all transactions due today or earlier
  final dueTransactions = await dbHelper.getDueRecurringTransactions(today);

  for (var tx in dueTransactions) {
    // 1. Add this as a normal transaction
    final newTransaction = tx_model.Transaction(
      accountId: tx.accountId,
      type: tx.type,
      category: tx.category,
      amount: tx.amount,
      date: tx.nextDate, // Use the date it was due
      notes: tx.notes,
    );
    await dbHelper.insertTransaction(newTransaction);

    // 2. Calculate the *next* due date
    DateTime nextDate;
    if (tx.frequency == 'monthly') {
      nextDate = DateTime(tx.nextDate.year, tx.nextDate.month + 1, tx.nextDate.day);
    } else if (tx.frequency == 'weekly') {
      nextDate = tx.nextDate.add(const Duration(days: 7));
    } else {
      // Default: set it for next month if frequency is unknown
      nextDate = DateTime(tx.nextDate.year, tx.nextDate.month + 1, tx.nextDate.day);
    }
    
    // 3. Update the recurring transaction with its new nextDate
    await dbHelper.updateRecurringTransactionNextDate(tx.id!, nextDate);
  }
}

// Note: The _setupNativeChannel() function has been completely removed
// as it is no longer needed by the simplified settings screen.

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartExpense',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/account.dart';
import 'package:se/models/transaction.dart' as tx_model;
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';
import 'package:se/widgets/custom_numpad.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _amountString = "0";

  final List<String> _incomeCategories = ['Salary', 'Gifts', 'Rental Revenue', 'Other'];
  final List<String> _expenseCategories = ['Food', 'Transport', 'Rent', 'Bills', 'Shopping', 'Entertainment', 'Other'];
  
  String? _selectedCategory;

  Account? _selectedAccount;
  List<Account> _accounts = [];
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _selectedCategory = _expenseCategories.first;
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper.instance.getAccountsWithBalance();
    setState(() {
      _accounts = accounts;
      if (_accounts.isNotEmpty) {
        _selectedAccount = _accounts.first;
      }
    });
  }

  void _onNumpadTapped(String value) {
    setState(() {
      if (value == "DEL") {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = "0";
        }
      } else if (_amountString == "0") {
        _amountString = value;
      } else if (_amountString.length < 10) {
        _amountString += value;
      }
    });
  }

  void _onNumpadDotTapped() {
    setState(() {
      if (!_amountString.contains('.')) {
        _amountString += ".";
      }
    });
  }

  Future<void> _saveTransaction() async {
    final double amount = double.tryParse(_amountString) ?? 0.0;

    if (amount == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount greater than zero."),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return; 
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an account."),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a category."),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    final newTransaction = tx_model.Transaction(
      accountId: _selectedAccount!.id!,
      type: _isExpense ? 'expense' : 'income',
      category: _selectedCategory!,
      amount: amount,
      date: _selectedDate,
      notes: _notesController.text,
    );

    try {
      await DatabaseHelper.instance.insertTransaction(newTransaction);
      if (mounted) {
        Navigator.of(context).pop(true); // Send 'true' back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save transaction: $e"),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isExpense ? "New Expense" : "New Income"),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              "Done",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ToggleButtons(
              isSelected: [_isExpense, !_isExpense],
              onPressed: (index) {
                setState(() {
                  _isExpense = index == 0;
                  _selectedCategory = (_isExpense ? _expenseCategories : _incomeCategories).first;
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              selectedColor: Colors.white,
              fillColor: _isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text("Expense"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text("Income"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              "\$${NumberFormat("#,##0.00", "en_US").format(double.tryParse(_amountString) ?? 0.0)}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.category, color: AppTheme.lightText),
                  title: Text("Category", style: Theme.of(context).textTheme.bodyLarge),
                  trailing: DropdownButton<String>(
                    value: _selectedCategory,
                    items: currentCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    underline: Container(), 
                    icon: const Icon(Icons.chevron_right, color: AppTheme.lightText),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet, color: AppTheme.lightText),
                  title: Text("Account", style: Theme.of(context).textTheme.bodyLarge),
                  trailing: DropdownButton<Account>(
                    value: _selectedAccount,
                    items: _accounts.isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text("Loading..."))]
                        : _accounts.map((Account account) {
                            return DropdownMenuItem<Account>(
                              value: account,
                              child: Text(account.name),
                            );
                          }).toList(),
                    onChanged: (Account? newValue) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    },
                    underline: Container(), 
                    icon: const Icon(Icons.chevron_right, color: AppTheme.lightText),
                  ),
                ),
                _buildFormTile(
                  context,
                  icon: Icons.calendar_today,
                  title: "Date",
                  trailing: DateFormat.yMd().format(_selectedDate),
                  onTap: () => _selectDate(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.notes),
                      labelText: "Notes",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomNumpad(
            onNumberTap: _onNumpadTapped,
            onDotTap: _onNumpadDotTapped,
            onDeleteTap: () => _onNumpadTapped("DEL"),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.lightText),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkText,
                ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.lightText),
        ],
      ),
      onTap: onTap,
    );
  }
}
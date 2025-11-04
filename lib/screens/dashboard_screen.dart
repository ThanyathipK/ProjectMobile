import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/account.dart';
import 'package:se/screens/account_detail_screen.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';
import 'package:se/widgets/account_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  final dbHelper = DatabaseHelper.instance;
  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final accounts = await dbHelper.getAccountsWithBalance();
    final totalBalance = await dbHelper.getOverallBalance();
    return {
      'accounts': accounts,
      'totalBalance': totalBalance,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No data found."));
        }

        final List<Account> accounts = snapshot.data!['accounts'];
        final double totalBalance = snapshot.data!['totalBalance'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalBalanceCard(context, totalBalance),
              
              const SizedBox(height: 24),
              
              Text(
                "Your Accounts",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return AccountCard(
                    accountName: account.name,
                    balance: formatter.format(account.balance),
                    // Change is not calculated, so we pass an empty string
                    change: "", 
                    changeColor: account.balance >= 0 
                                  ? AppTheme.primaryGreen 
                                  : AppTheme.primaryRed,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AccountDetailScreen(
                            account: account, // Pass the whole account object
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double balance) {
    final isNegative = balance < 0;
    return Card(
      color: isNegative ? AppTheme.primaryRed : AppTheme.primaryGreen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Balance",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${formatter.format(balance)}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
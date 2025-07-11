import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/auth_service.dart';
import 'package:wallet/providers/shared_preference.dart';
import 'package:wallet/providers/transaksi_provider.dart';
import 'package:wallet/widdgets/add_edit_transaction.dart';
import 'package:wallet/widdgets/expenses_donut_chart.dart';
import 'package:wallet/widdgets/finance_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    print("--- HOME_SCREEN LOAD DATA ---");
    print("Current User saat di HomeScreen: ${currentUser?.email}");
    print("---------------------------");

    Future.microtask(() {
      Provider.of<TransaksiProvider>(context, listen: false).fetchTransactions();
    });
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await SharedPrefService.getUser();
    if (mounted && data != null) {
      setState(() {
        username = data['username'];
      });
    }
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    await SharedPrefService.clear();
    // AuthGate akan secara otomatis menangani navigasi ke halaman login
  }
  
  // Sisa kode di HomeScreen sama seperti sebelumnya...
  String _formatCurrency(double amount, {bool showSymbol = true}) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: showSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = context.watch<TransaksiProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 26, 204, 124),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              if (username != null)
                Text(
                  'Halo, $username',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Keluar',
              onPressed: () async {
                 await AuthService().logout();
                 await SharedPrefService.clear();
              }
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.yellow,
            tabs: [Tab(text: 'DASHBOARD'), Tab(text: 'RIWAYAT')],
          ),
        ),
        body:
            transaksiProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildDashboard(context),
                      _buildTransactionList(context),
                    ],
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddEditTransactionSheet(),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Tambah Transaksi',
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final transaksi = context.watch<TransaksiProvider>();

    if (transaksi.transactions.isEmpty) {
      return const Center(child: Text('Data masih kosong.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBalanceCard(transaksi),
          const SizedBox(height: 16),
          const ExpensesDonutChart(),
          const SizedBox(height: 16),
          const FinanceChart(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(TransaksiProvider transaksi) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Wallet Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Performa 30 hari terakhir",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGaugeItem("Saldo", transaksi.balance, Colors.blue),
                _buildGaugeItem(
                  "Pemasukan",
                  transaksi.totalIncome,
                  Colors.green,
                ),
                _buildGaugeItem(
                  "Pengeluaran",
                  transaksi.totalExpense,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeItem(String title, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrency(value),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final transaksi = context.watch<TransaksiProvider>();

    if (transaksi.transactions.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada transaksi.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: transaksi.transactions.length,
      itemBuilder: (context, index) {
        final transaction = transaksi.transactions[index];
        final isIncome = transaction.type?.toLowerCase() == 'pemasukan';

        final iconData =
            isIncome ? Icons.account_balance_wallet : Icons.shopping_cart;
        final color = isIncome ? Colors.green : Colors.redAccent;
        final title = transaction.description ?? '-';
        final subtitle =
            isIncome
                ? 'Pemasukan dari ${transaction.category ?? 'Tidak diketahui'}'
                : 'Pengeluaran untuk ${transaction.category ?? 'Tidak diketahui'}';
        final amountString =
            '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount?.toDouble() ?? 0)}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(iconData, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            trailing: Text(
              amountString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder:
                    (_) => AddEditTransactionSheet(transaction: transaction),
              );
            },
          ),
        );
      },
    );
  }
}
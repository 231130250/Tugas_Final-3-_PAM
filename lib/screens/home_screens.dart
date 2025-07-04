import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wallet/providers/waallet_providers.dart';
import 'package:wallet/widdgets/add_edit_transaction.dart';
import 'package:wallet/widdgets/expenses_donut_chart.dart';
// Widget baru untuk donut chart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper untuk format Rupiah
  String _formatCurrency(double amount, {bool showSymbol = true}) {
    final format = NumberFormat.currency(
        locale: 'id_ID', symbol: showSymbol ? 'Rp ' : '', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Kita buat 2 tab
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Background agar kartu terlihat
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 26, 204, 124),
          title: const Text('Wallet Dashboard', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.yellow,
            tabs: [
              Tab(text: 'DASHBOARD'),
              Tab(text: 'RIWAYAT'),
            ],
          ),
        ),
        body: Consumer<WalletProvider>(
          builder: (context, wallet, child) {
            return TabBarView(
              children: [
                // Konten Tab 1: Dashboard
                _buildDashboard(context, wallet),
                // Konten Tab 2: Riwayat Transaksi
                _buildTransactionList(context, wallet),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddEditTransactionSheet(),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Tambah Transaksi',
        ),
      ),
    );
  }

  // WIDGET UNTUK TAB DASHBOARD
  Widget _buildDashboard(BuildContext context, WalletProvider wallet) {
    if (wallet.transactions.isEmpty) {
      return const Center(child: Text('Data masih kosong.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card untuk "Wallet Dashboard" (mirip panel kanan)
          _buildBalanceCard(wallet),
          const SizedBox(height: 16),
          // Card untuk "Expenses Structure" (mirip panel tengah)
          ExpensesDonutChart(wallet: wallet), // Menggunakan widget baru
        ],
      ),
    );
  }

  // WIDGET UNTUK KARTU SALDO
  Widget _buildBalanceCard(WalletProvider wallet) {
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
                _buildGaugeItem("Saldo", wallet.balance, Colors.blue),
                _buildGaugeItem("Pemasukan", wallet.totalIncome, Colors.green),
                _buildGaugeItem("Pengeluaran", wallet.totalExpense, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // WIDGET UNTUK ITEM DI KARTU SALDO (simulasi gauge)
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
                value: 1.0, // simplified, just for looks
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
        )
      ],
    );
  }

  // WIDGET UNTUK TAB RIWAYAT TRANSAKSI
  Widget _buildTransactionList(BuildContext context, WalletProvider wallet) {
    if (wallet.transactions.isEmpty) {
      return const Center(
          child: Text('Belum ada transaksi.',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: wallet.transactions.length,
      itemBuilder: (context, index) {
        final transaction = wallet.transactions[index];
        bool isIncome = transaction is IncomeTransaction;
        
        // Data untuk tampilan
        final iconData = isIncome ? Icons.account_balance_wallet : Icons.shopping_cart;
        final color = isIncome ? Colors.green : Colors.redAccent;
        final title = transaction.description;
        final subtitle = isIncome
            // ignore: unnecessary_cast
            ? 'Pemasukan dari ${(transaction as IncomeTransaction).source}'
            : 'Pengeluaran untuk ${(transaction as ExpenseTransaction).category}';
        final amountString = '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(iconData, color: color),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            trailing: Text(amountString,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 15)),
             onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddEditTransactionSheet(transaction: transaction),
                );
              },
          ),
        );
      },
    );
  }
}
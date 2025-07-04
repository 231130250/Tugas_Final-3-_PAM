import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:wallet/providers/waallet_providers.dart';

class ExpensesDonutChart extends StatelessWidget {
  final WalletProvider wallet;
  const ExpensesDonutChart({super.key, required this.wallet});

  // Helper untuk format Rupiah
  String _formatCurrency(double amount, {bool showSymbol = true}) {
    final format = NumberFormat.currency(
        locale: 'id_ID', symbol: showSymbol ? 'Rp ' : '', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = wallet.expenseByCategory;
    if (expenseData.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan jika tidak ada pengeluaran
    }
    
    // Siapkan data untuk chart
    int colorIndex = 0;
    final List<Color> chartColors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.pink];
    final chartSections = expenseData.entries.map((entry) {
      final color = chartColors[colorIndex % chartColors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / wallet.totalExpense * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Expenses Structure",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: chartSections,
                      centerSpaceRadius: 70, // Ini yang membuatnya menjadi Donut Chart
                      sectionsSpace: 2,
                    ),
                  ),
                  Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text("Total", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                       Text(
                         _formatCurrency(wallet.totalExpense),
                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                       ),
                     ],
                  )
                ],
              ),
            ),
            const Divider(height: 24),
            // Legenda Chart
             Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: expenseData.keys.map((category) {
                 final color = chartColors[expenseData.keys.toList().indexOf(category) % chartColors.length];
                 return _buildLegend(color, category);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
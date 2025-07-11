import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/transaksi_provider.dart';

class ExpensesDonutChart extends StatelessWidget {
  const ExpensesDonutChart({super.key});

  String _formatCurrency(double amount, {bool showSymbol = true}) {
    final format = NumberFormat.currency(
        locale: 'id_ID', symbol: showSymbol ? 'Rp ' : '', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = context.watch<TransaksiProvider>();
    final expenseData = transaksiProvider.expenseByCategory;
    final totalExpense = transaksiProvider.totalExpense;

    if (expenseData.isEmpty || totalExpense == 0) {
      return const SizedBox.shrink(); // Sembunyikan jika tidak ada data
    }

    int colorIndex = 0;
    final List<Color> chartColors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.indigo,
    ];

    final chartSections = expenseData.entries.map((entry) {
      final color = chartColors[colorIndex % chartColors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / totalExpense * 100).toStringAsFixed(0)}%',
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
              "Struktur Pengeluaran",
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
                      centerSpaceRadius: 70,
                      sectionsSpace: 2,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      Text(
                        _formatCurrency(totalExpense),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(height: 24),
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

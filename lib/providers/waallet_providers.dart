import 'package:flutter/material.dart';

// Kelas Abstrak
abstract class Transaction {
  int id;
  double _amount;
  String description;
  DateTime date;

  Transaction(this.id, double amount, this.description, this.date)
      : _amount = amount;

  double get amount => _amount;

  set amount(double value) {
    if (value <= 0) {
      throw Exception("Jumlah harus lebih dari 0");
    }
    _amount = value;
  }
}

// Kelas Pemasukan
class IncomeTransaction extends Transaction {
  String source;
  IncomeTransaction(
      int id, double amount, String description, DateTime date, this.source)
      : super(id, amount, description, date);
}

// Kelas Pengeluaran
class ExpenseTransaction extends Transaction {
  String category;
  ExpenseTransaction(
      int id, double amount, String description, DateTime date, this.category)
      : super(id, amount, description, date);
}

// Provider sebagai pusat logika dan data
class WalletProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  int _idCounter = 1;

  List<Transaction> get transactions => _transactions;

  void addTransaction(Transaction transaction) {
    if (transaction.amount <= 0) {
      throw Exception("Jumlah tidak boleh nol atau negatif.");
    }
    transaction.id = _idCounter++;
    _transactions.insert(0, transaction); // Tampilkan yang terbaru di atas
    notifyListeners(); // Beri tahu UI untuk update
  }

  void updateTransaction(int id, double newAmount, String newDesc) {
    var transaction = _transactions.firstWhere((t) => t.id == id);
    transaction.amount = newAmount;
    transaction.description = newDesc;
    notifyListeners();
  }

  void deleteTransaction(int id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double get totalIncome {
    return _transactions
        .whereType<IncomeTransaction>()
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .whereType<ExpenseTransaction>()
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  // GETTER BARU: Untuk mengelompokkan pengeluaran per kategori
  Map<String, double> get expenseByCategory {
    final Map<String, double> data = {};
    for (var t in _transactions.whereType<ExpenseTransaction>()) {
      if (data.containsKey(t.category)) {
        data[t.category] = data[t.category]! + t.amount;
      } else {
        data[t.category] = t.amount;
      }
    }
    return data;
  }
}
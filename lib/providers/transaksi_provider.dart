import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/transaksi_model.dart';

class TransaksiProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  List<TransaksiModel> _transactions = [];
  List<TransaksiModel> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.type?.toLowerCase() == 'pemasukan')
      .fold(0.0, (sum, t) => sum + (t.amount?.toDouble() ?? 0));

  double get totalExpense => _transactions
      .where((t) => t.type?.toLowerCase() == 'pengeluaran')
      .fold(0.0, (sum, t) => sum + (t.amount?.toDouble() ?? 0));

  double get balance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final Map<String, double> data = {};
    for (var t in _transactions.where((t) => t.type == 'pengeluaran')) {
      final cat = t.category ?? 'Lainnya';
      data[cat] = (data[cat] ?? 0) + (t.amount?.toDouble() ?? 0);
    }
    return data;
  }

  Future<void> fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _db
          .collection('transaksi')
          .where('id_user', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransaksiModel.fromJson(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Gagal ambil transaksi: $e');
    }
  }

  Future<void> addTransaction(TransaksiModel transaksi) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('transaksi').doc();
    transaksi.idUser = user.uid;
    transaksi.idTransaksi = docRef.id;
    transaksi.timestamp = DateTime.now().toIso8601String();

    try {
      await docRef.set(transaksi.toJson());
      _transactions.insert(0, transaksi); // Tambah langsung ke UI
      notifyListeners();
    } catch (e) {
      print('Gagal tambah transaksi: $e');
    }
  }

  Future<void> updateTransaction(String idTransaksi, {
    required double newAmount,
    required String newDesc,
  }) async {
    try {
      await _db.collection('transaksi').doc(idTransaksi).update({
        'amount': newAmount,
        'description': newDesc,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final index = _transactions.indexWhere((t) => t.idTransaksi == idTransaksi);
      if (index != -1) {
        _transactions[index].amount = newAmount.toInt();
        _transactions[index].description = newDesc;
        _transactions[index].timestamp = DateTime.now().toIso8601String();
        notifyListeners();
      }
    } catch (e) {
      print('Gagal update transaksi: $e');
    }
  }

  Future<void> deleteTransaction(String idTransaksi) async {
    try {
      await _db.collection('transaksi').doc(idTransaksi).delete();
      _transactions.removeWhere((t) => t.idTransaksi == idTransaksi);
      notifyListeners();
    } catch (e) {
      print('Gagal hapus transaksi: $e');
    }
  }

  Future<List<TransaksiModel>> filterByTypeAndCategory({
    String? type,
    String? category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      Query query = _db.collection('transaksi').where('id_user', isEqualTo: user.uid);
      if (type != null) query = query.where('type', isEqualTo: type);
      if (category != null) query = query.where('category', isEqualTo: category);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => TransaksiModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Gagal filter: $e");
      return [];
    }
  }
}

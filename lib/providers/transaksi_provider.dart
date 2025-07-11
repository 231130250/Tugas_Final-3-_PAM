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

    print("--- MEMULAI FETCH TRANSACTIONS ---");
    if (user == null) {
      print("GAGAL: Pengguna tidak ditemukan (user is null). Proses fetch dihentikan.");
      _transactions = [];
      notifyListeners();
      return;
    }
    print("INFO: Fetching data untuk user ID: ${user.uid}");

    setLoading(true);
    try {
      final snapshot = await _db
          .collection('transaksi')
          .where('id_user', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      print("INFO: Query berhasil. Ditemukan ${snapshot.docs.length} dokumen.");

      if (snapshot.docs.isEmpty) {
        _transactions = [];
      } else {
        List<TransaksiModel> newTransactions = [];
        for (var doc in snapshot.docs) {
          try {
            print("Mencoba memproses dokumen: ${doc.id}");
            newTransactions.add(TransaksiModel.fromJson(doc.data()));
          } catch (e) {
            print("!!! ERROR PARSING DOKUMEN ${doc.id}: $e");
            print("DATA MENTAH DOKUMEN: ${doc.data()}");
          }
        }
        _transactions = newTransactions;
      }
      print("INFO: Proses selesai. Total transaksi di provider: ${_transactions.length}");
    } catch (e) {
      print("!!! ERROR UTAMA SAAT FETCHING: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> addTransaction(TransaksiModel transaksi) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("Error: Current user is null. Aborting transaction.");
      return;
    }

    final docRef = _db.collection('transaksi').doc();
    transaksi.idUser = user.uid;
    transaksi.idTransaksi = docRef.id;
    transaksi.timestamp = DateTime.now().toIso8601String();

    try {
      await docRef.set(transaksi.toJson());
      await fetchTransactions();
    } catch (e) {
      print('EXCEPTION during addTransaction: $e');
      throw e;
    }
  }
  
  // Fungsi update dan delete tidak perlu diubah
  Future<void> updateTransaction(String idTransaksi, {
    required double newAmount,
    required String newDesc,
  }) async {
    try {
      await _db.collection('transaksi').doc(idTransaksi).update({
        'amount': newAmount.toInt(),
        'description': newDesc,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await fetchTransactions();
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
}
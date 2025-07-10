import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet/model/transaction_model.dart';


class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ DITAMBAH: Simpan user saat login
  Future<void> saveUserData(String uid, String email) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
    }, SetOptions(merge: true));
  }

  // ✅ DITAMBAH: Ambil UID berdasarkan email
  Future<String?> getUidFromEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // ✅ UID sebagai docId
    }
    return null;
  }

  // ✅ DITAMBAH: Ambil transaksi berdasarkan email
  Future<List<TransactionModel>> getTransactionsByEmail(String email) async {
    final uid = await getUidFromEmail(email);
    if (uid == null) return [];
    return await getTransactions(uid); // ✅ pakai UID
  }

  // ✅ DITAMBAH: Tambahkan transaksi baru
  Future<void> addTransaction(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('transactions').add(data);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TransactionModel {
  final String type;
  final double amount;
  final String description;
  final Timestamp timestamp;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    String type = map['type'];

    if (type == 'pemasukan') {
      return Pemasukan.fromMap(map);
    } else if (type == 'pengeluaran') {
      return Pengeluaran.fromMap(map);
    } else {
      throw Exception('Tipe transaksi tidak dikenal: $type');
    }
  }
}

class Pemasukan extends TransactionModel {
  final String source;

  Pemasukan({
    required double amount,
    required String description,
    required Timestamp timestamp,
    required this.source,
  }) : super(
          type: 'pemasukan',
          amount: amount,
          description: description,
          timestamp: timestamp,
        );

  factory Pemasukan.fromMap(Map<String, dynamic> map) {
    return Pemasukan(
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      source: map['source'] ?? 'Tidak diketahui',
    );
  }
}

class Pengeluaran extends TransactionModel {
  final String category;

  Pengeluaran({
    required double amount,
    required String description,
    required Timestamp timestamp,
    required this.category,
  }) : super(
          type: 'pengeluaran',
          amount: amount,
          description: description,
          timestamp: timestamp,
        );

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      category: map['category'] ?? 'Lain-lain',
    );
  }
}

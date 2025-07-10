class TransaksiModel {
  Users? users;

  TransaksiModel({this.users});

  TransaksiModel.fromJson(Map<String, dynamic> json) {
    users = json['users'] != null ? new Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}

class Users {
  UidAbc123? uidAbc123;

  Users({this.uidAbc123});

  Users.fromJson(Map<String, dynamic> json) {
    uidAbc123 = json['uid_abc123'] != null
        ? new UidAbc123.fromJson(json['uid_abc123'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.uidAbc123 != null) {
      data['uid_abc123'] = this.uidAbc123!.toJson();
    }
    return data;
  }
}

class UidAbc123 {
  String? nama;
  String? email;
  Transactions? transactions;

  UidAbc123({this.nama, this.email, this.transactions});

  UidAbc123.fromJson(Map<String, dynamic> json) {
    nama = json['nama'];
    email = json['email'];
    transactions = json['transactions'] != null
        ? new Transactions.fromJson(json['transactions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nama'] = this.nama;
    data['email'] = this.email;
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.toJson();
    }
    return data;
  }
}

class Transactions {
  TxnAutoId1? txnAutoId1;
  TxnAutoId2? txnAutoId2;

  Transactions({this.txnAutoId1, this.txnAutoId2});

  Transactions.fromJson(Map<String, dynamic> json) {
    txnAutoId1 = json['txn_auto_id_1'] != null
        ? new TxnAutoId1.fromJson(json['txn_auto_id_1'])
        : null;
    txnAutoId2 = json['txn_auto_id_2'] != null
        ? new TxnAutoId2.fromJson(json['txn_auto_id_2'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.txnAutoId1 != null) {
      data['txn_auto_id_1'] = this.txnAutoId1!.toJson();
    }
    if (this.txnAutoId2 != null) {
      data['txn_auto_id_2'] = this.txnAutoId2!.toJson();
    }
    return data;
  }
}

class TxnAutoId1 {
  String? type;
  int? amount;
  String? description;
  String? category;
  String? timestamp;

  TxnAutoId1(
      {this.type,
      this.amount,
      this.description,
      this.category,
      this.timestamp});

  TxnAutoId1.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    amount = json['amount'];
    description = json['description'];
    category = json['category'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['category'] = this.category;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class TxnAutoId2 {
  String? type;
  int? amount;
  String? description;
  String? source;
  String? timestamp;

  TxnAutoId2(
      {this.type, this.amount, this.description, this.source, this.timestamp});

  TxnAutoId2.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    amount = json['amount'];
    description = json['description'];
    source = json['source'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['source'] = this.source;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

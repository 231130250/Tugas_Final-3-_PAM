class TransaksiModel {
  String? idUser;
  String? idTransaksi;
  String? type;
  int? amount;
  String? description;
  String? category;
  String? timestamp;

  TransaksiModel(
      {this.idUser,
      this.idTransaksi,
      this.type,
      this.amount,
      this.description,
      this.category,
      this.timestamp});

  TransaksiModel.fromJson(Map<String, dynamic> json) {
    idUser = json['id_user'];
    idTransaksi = json['id_transaksi'];
    type = json['type'];
    amount = json['amount'];
    description = json['description'];
    category = json['category'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_user'] = this.idUser;
    data['id_transaksi'] = this.idTransaksi;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['category'] = this.category;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

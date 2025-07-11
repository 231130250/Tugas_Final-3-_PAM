import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String pin;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.pin,
    required this.createdAt,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'],
      username: map['username'],
      pin: map['pin'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

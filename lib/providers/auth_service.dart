import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet/model/user_model.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String username,
    required String pin,
  }) async {
    await _db.collection('users').add({
      'email': email,
      'username': username,
      'pin': pin,
      'createdAt': DateTime.now(),
    });
  }

  Future<AppUser?> loginUser(String email, String pin) async {
    final query =
        await _db
            .collection('users')
            .where('email', isEqualTo: email)
            .where('pin', isEqualTo: pin)
            .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return AppUser.fromMap(doc.id, doc.data());
    } else {
      return null;
    }
  }
}

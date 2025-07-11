// Salin dan ganti seluruh isi file lib/providers/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet/model/user_model.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> registerUser({
    required String email,
    required String username,
    required String pin,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pin,
      );

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'pin': pin,
        'createdAt': DateTime.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException on register: ${e.message}");
      throw e;
    }
  }

  Future<AppUser?> loginUser(String email, String pin) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: pin, // Gunakan PIN sebagai password
      );

      final userUid = _auth.currentUser!.uid;
      final doc = await _db.collection('users').doc(userUid).get();

      if (doc.exists) {
        // --- DIAGNOSTIK 1: Memeriksa data dari Firestore ---
        print('--- DATA DARI FIRESTORE ---');
        print(doc.data());
        // ----------------------------------------------------
        return AppUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException on login: ${e.message}");
      throw e;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
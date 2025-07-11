// Salin dan ganti seluruh isi file lib/providers/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet/model/user_model.dart';
import 'package:wallet/screens/home_screens.dart';
import 'package:wallet/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // JIKA SUDAH LOGIN, JANGAN LANGSUNG KE HOME
          // TAPI, PANGGIL WIDGET PENGAMBIL DATA PENGGUNA
          return UserDataLoader(userId: snapshot.data!.uid);
        }

        // Jika tidak ada sesi login, ke halaman login
        return const LoginScreen();
      },
    );
  }
}

// WIDGET BARU: Pos pemeriksaan untuk mengambil data profil pengguna
class UserDataLoader extends StatefulWidget {
  final String userId;
  const UserDataLoader({super.key, required this.userId});

  @override
  State<UserDataLoader> createState() => _UserDataLoaderState();
}

class _UserDataLoaderState extends State<UserDataLoader> {
  // Fungsi ini HANYA untuk mengambil data dari Firestore
  Future<AppUser?> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error di UserDataLoader: $e");
      return null; // Jika gagal, akan diarahkan ke login
    }
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder akan menampilkan UI berdasarkan status Future
    return FutureBuilder<AppUser?>(
      future: _fetchUserData(),
      builder: (context, userSnapshot) {
        // Saat data sedang diambil, tampilkan loading
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Jika terjadi error atau data pengguna tidak ada
        if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
          // Maka, paksa kembali ke halaman login untuk keamanan
          return const LoginScreen();
        }

        // JIKA BERHASIL: Data pengguna (AppUser) sudah didapat.
        // Sekarang baru kita tampilkan HomeScreen dan KIRIM data tersebut.
        return HomeScreen(user: userSnapshot.data!);
      },
    );
  }
}
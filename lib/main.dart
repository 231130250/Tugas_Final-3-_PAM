import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wallet/providers/waallet_providers.dart';
import 'package:wallet/screens/login_screen.dart';

void main() {
  // Inisialisasi format lokal (untuk tanggal Indonesia)
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan ChangeNotifierProvider untuk state management
    return ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: MaterialApp(
        title: 'Aplikasi Wallet',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Menambahkan tema agar tombol di keypad tidak memiliki highlight
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
          ),
        ),
        // Mulai aplikasi dari LoginScreen
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
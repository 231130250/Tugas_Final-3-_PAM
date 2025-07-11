import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wallet/firebase_options.dart';
import 'package:wallet/providers/shared_preference.dart';
import 'package:wallet/providers/transaksi_provider.dart';
import 'package:wallet/screens/home_screens.dart';
import 'package:wallet/screens/login_screen.dart';
import 'package:wallet/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  // Cek apakah user sudah login sebelumnya
  final userData = await SharedPrefService.getUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TransaksiProvider()..fetchTransactions(),
        ),
      ],
      child: MyApp(isLoggedIn: userData != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Wallet',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/register': (_) => const RegisterScreen(), // ✅ ini penting
      },
    );
  }
}

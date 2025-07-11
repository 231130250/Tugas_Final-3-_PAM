import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:wallet/firebase_options.dart';
import 'package:wallet/providers/auth_gate.dart';
import 'package:wallet/providers/transaksi_provider.dart';
import 'package:wallet/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TransaksiProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const AuthGate(),
      routes: {
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
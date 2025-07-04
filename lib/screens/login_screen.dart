import 'package:flutter/material.dart';
import 'package:wallet/screens/home_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";
  bool _isLoading = false;

  void _onNumberPress(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == 6) {
        // Simulasi proses loading dan verifikasi PIN
        setState(() {
          _isLoading = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          // Navigasi ke halaman utama jika PIN "benar"
          // Dalam aplikasi nyata, Anda akan memverifikasi PIN dengan backend
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      }
    }
  }

  void _onBackspacePress() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Widget _buildPinIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 6; i++) {
      indicators.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < _pin.length ? Colors.orange : Colors.grey[300],
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  Widget _buildKeypadButton(
    String label, {
    VoidCallback? onPressed,
    IconData? icon,
    bool isIcon = false,
  }) {
    return TextButton(
      onPressed: onPressed ?? () => _onNumberPress(label),
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.grey[200],
        minimumSize: const Size(70, 70),
      ),
      child:
          isIcon
              ? Icon(icon, size: 30, color: Colors.black87)
              : Text(
                label,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                // Ganti dengan path logo Anda
                Image.asset('assets/images/logo aplikasi.png', height: 100),
                const SizedBox(height: 40),
                const Text(
                  'Selamat datang kembali.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                _buildPinIndicator(),
                const SizedBox(height: 15),
                const Text(
                  'Masukkan PIN kamu',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Spacer(),
                _buildKeypad(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ganti dengan logo atau CircularProgressIndicator
                        Image.asset(
                          'assets/images/gambarloading.png',
                          height: 300,
                        ),
                        const SizedBox(height: 15),
                        const Text("Memuat..."),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(padding: const EdgeInsets.all(30), child: SizedBox()),
            _buildKeypadButton('0'),
            _buildKeypadButton(
              '',
              isIcon: true,
              icon: Icons.backspace_outlined,
              onPressed: _onBackspacePress,
            ),
          ],
        ),
      ],
    );
  }
}

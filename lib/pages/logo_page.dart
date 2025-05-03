import 'package:flutter/material.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Satoshi Index'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Image.asset(
          'lib/assets/images/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

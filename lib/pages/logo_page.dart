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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('lib/assets/images/logo.png', width: 200, height: 200),
            const SizedBox(height: 24),
            const Text(
              "Satoshi Index est une application pédagogique qui permet de visualiser l'évolution des prix des produits du quotidien en euros (€) et en bitcoins (₿), exprimés en satoshis. "
              "Elle propose des graphiques interactifs, un tableau de données trimestrielles, et permet de mieux comprendre l’impact de l’inflation ainsi que le pouvoir d’achat à travers le prisme du Bitcoin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'whitepaper_page.dart';

class SatoshiPage extends StatelessWidget {
  const SatoshiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satoshi to Bitcoin'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Comprendre le satoshi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Le satoshi (ou sat) est la plus petite unité de Bitcoin, "
              "comme le centime pour l’euro. Comprendre cette échelle permet de mieux "
              "saisir les prix en satoshis affichés dans l’application.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            /*
            const SizedBox(height: 16),
            const Text(
              "🔸 1 satoshi = 0.00 000 001 BTC\n"
              "🔸 100 000 000 satoshis = 1 BTC",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),*/
            const SizedBox(height: 16),
            Expanded(
              child: Image.asset(
                'lib/assets/images/Bitcoin_to_satoshi.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WhitepaperPage()),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Lire le Whitepaper de Bitcoin"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

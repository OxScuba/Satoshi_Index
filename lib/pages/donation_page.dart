import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const lightningAddress = "Scuba_Wizard@getalby.com";

    return Scaffold(
      appBar: AppBar(title: const Text('Tip me in Bitcoin')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Merci pour votre soutien 🧡",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'lib/assets/images/donation_qr.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lightningAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: lightningAddress),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Adresse copiée dans le presse-papiers !",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Scan pour envoyer un tip en Bitcoin",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

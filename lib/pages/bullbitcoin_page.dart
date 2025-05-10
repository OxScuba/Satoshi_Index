import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BullBitcoinPage extends StatelessWidget {
  const BullBitcoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acheter du Bitcoin"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://www.bullbitcoin.com/fr");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Image.asset(
                'lib/assets/images/logo_bullbitcoin.png',
                width: 180,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bull Bitcoin est un service non-custodial pour acheter et vendre du Bitcoin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Contrairement aux plateformes centralisées comme Binance ou Coinbase, Bull Bitcoin ne garde jamais vos bitcoins. "
              "Vous les recevez directement dans votre portefeuille personnel. Vous gardez ainsi le contrôle total de vos clés privées.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              "Vous pouvez acheter du bitcoin en quelques minutes par virement bancaire.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                "Aller sur Bull Bitcoin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final url = Uri.parse(
                  "https://app.bullbitcoin.com/registration/scuba",
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://youtu.be/dJY_zyCV7HM");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Image.asset(
                'lib/assets/images/tuto_bullbitcoin_par_howtobitcoin.png',
                width: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

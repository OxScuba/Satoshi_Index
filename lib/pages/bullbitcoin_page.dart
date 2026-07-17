import 'package:flutter/material.dart' hide RichText, Text, TextSpan;
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';

class BullBitcoinPage extends StatelessWidget {
  const BullBitcoinPage({super.key});

  Future<void> _open(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicUrl = Uri.parse(
      AppTranslations.isEnglish
          ? 'https://www.bullbitcoin.com/'
          : 'https://www.bullbitcoin.com/fr',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter du Bitcoin'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _open(publicUrl),
              child: Image.asset(
                'lib/assets/images/logo_bullbitcoin.png',
                width: 180,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bull Bitcoin est un service non-custodial pour acheter et vendre du Bitcoin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contrairement aux plateformes centralisées comme Binance ou Coinbase, Bull Bitcoin ne garde jamais vos bitcoins.\n'
              'Vous les recevez directement dans votre portefeuille personnel.\n'
              'Vous gardez ainsi le contrôle total de vos clés privées.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous pouvez acheter du bitcoin en quelques minutes par virement bancaire.',
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
                'Aller sur Bull Bitcoin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed:
                  () => _open(
                    Uri.parse('https://app.bullbitcoin.com/registration/scuba'),
                  ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _open(Uri.parse('https://youtu.be/dJY_zyCV7HM')),
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

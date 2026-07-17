import 'package:flutter/material.dart' hide RichText, Text, TextSpan;
import 'package:flutter/services.dart';

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const lightningAddress = 'Scuba_Wizard@getalby.com';

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.tr('Tip me in Bitcoin'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTranslations.tr('Merci pour votre soutien '),
              style: const TextStyle(fontSize: 18),
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
                const UntranslatedText(
                  lightningAddress,
                  style: TextStyle(
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
                      SnackBar(
                        content: Text(
                          AppTranslations.tr(
                            'Adresse copiée dans le presse-papiers !',
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppTranslations.tr('Scan pour envoyer un tip en Bitcoin'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

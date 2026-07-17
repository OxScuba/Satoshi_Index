import 'package:flutter/material.dart' hide RichText, Text, TextSpan;
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';
import 'whitepaper_page.dart';

class SatoshiPage extends StatelessWidget {
  const SatoshiPage({super.key});

  Future<void> _launchPlanB() async {
    final url = Uri.parse('https://planb.network');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const explanation =
        "Le satoshi (ou sat) est la plus petite unité de Bitcoin, "
        "comme le centime pour l’euro.\n"
        "Comprendre cette échelle permet de mieux saisir les prix en "
        "satoshis affichés dans l’application.";

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Satoshi to Bitcoin')),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              AppTranslations.tr('Comprendre le satoshi'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.tr(explanation),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'lib/assets/images/Bitcoin_to_satoshi.png',
              fit: BoxFit.contain,
              height: 300,
            ),
            const SizedBox(height: 18),
            Text(
              AppTranslations.tr(
                "Pour apprendre sur la meilleure plateforme d'éducation "
                "gratuite sur Bitcoin c'est sur planb.network",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _launchPlanB,
              child: Image.asset(
                'lib/assets/images/planb_network_logo.png',
                height: 56,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WhitepaperPage(),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(AppTranslations.tr('Lire le Whitepaper de Bitcoin')),
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

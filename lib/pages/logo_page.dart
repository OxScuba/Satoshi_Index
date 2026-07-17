import 'package:flutter/material.dart' hide RichText, Text, TextSpan;

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const description =
        "Satoshi Index est une application pédagogique qui permet de "
        "visualiser l'évolution des prix des produits du quotidien en euros "
        "(€) et en bitcoins (₿), exprimés en satoshis.\n"
        "Elle propose des graphiques interactifs, un tableau de données "
        "trimestrielles, et permet de mieux comprendre l’impact de "
        "l’inflation ainsi que le pouvoir d’achat à travers le prisme du "
        "Bitcoin.";

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Satoshi Index')),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('lib/assets/images/logo.png', width: 200, height: 200),
            const SizedBox(height: 24),
            Text(
              AppTranslations.tr(description),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

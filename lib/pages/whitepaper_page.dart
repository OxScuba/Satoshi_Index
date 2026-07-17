import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide RichText, Text, TextSpan;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';

class WhitepaperPage extends StatelessWidget {
  static const _frenchAsset =
      'lib/assets/pdf/LivreBlanc_Verticale_31x21po_Blanc.pdf';
  static const _englishAsset = 'lib/assets/pdf/bitcoin-whitepaper-en.pdf';
  static const _spanishAsset = 'lib/assets/pdf/bitcoin-whitepaper-es.pdf';

  const WhitepaperPage({super.key});

  static String get _selectedAsset {
    if (AppTranslations.isSpanish) {
      return _spanishAsset;
    }

    if (AppTranslations.isEnglish) {
      return _englishAsset;
    }

    return _frenchAsset;
  }

  static String get _downloadFileName {
    if (AppTranslations.isSpanish) {
      return 'Libro_Blanco_Bitcoin.pdf';
    }

    if (AppTranslations.isEnglish) {
      return 'Bitcoin_White_Paper.pdf';
    }

    return 'LivreBlanc_Bitcoin.pdf';
  }

  Future<void> _downloadPdf(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisez le bouton de téléchargement du lecteur PDF.'),
        ),
      );
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw StateError('Dossier de téléchargement indisponible');
      }

      final file = File('${directory.path}/$_downloadFileName');

      final assetPath = _selectedAsset;
      final bytes = await DefaultAssetBundle.of(context).load(assetPath);
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF téléchargé avec succès ✅')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement : $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whitepaper de Bitcoin'),
        actions: [
          IconButton(
            tooltip: tr('Télécharger le PDF'),
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
          ),
        ],
      ),
      body: SfPdfViewer.asset(_selectedAsset),
    );
  }
}

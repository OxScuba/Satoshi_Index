import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WhitepaperPage extends StatelessWidget {
  const WhitepaperPage({super.key});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await rootBundle.load(
        'lib/assets/pdf/LivreBlanc_Verticale_31x21po_Blanc.pdf',
      );

      final directory = await getExternalStorageDirectory();
      final path = directory!.path;

      final file = File('$path/LivreBlanc_Bitcoin.pdf');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF téléchargé avec succès ✅")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du téléchargement : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Whitepaper de Bitcoin"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Télécharger le PDF",
            onPressed: () => _downloadPdf(context),
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        'lib/assets/pdf/LivreBlanc_Verticale_31x21po_Blanc.pdf',
      ),
    );
  }
}

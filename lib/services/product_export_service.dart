import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class ProductExportService {
  static Future<void> exportProducts(
    List<Product> products,
    double bitcoinPriceEUR,
  ) async {
    final data =
        products.map((product) {
          final latest = product.data.last;
          final sats =
              ((latest.priceEuro / bitcoinPriceEUR) * 100000000).round();
          final satsStr = _formatSats(sats);
          return {
            "id": product.id,
            "emoji": product.emoji,
            "name": product.name,
            "priceBTC": satsStr,
          };
        }).toList();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/product_data.json');
    await file.writeAsString(jsonEncode(data));
  }

  static String _formatSats(int sats) {
    final str = (sats / 100000000).toStringAsFixed(8);
    final parts = str.split('.');
    return "0.${parts[1].substring(0, 2)} ${parts[1].substring(2, 5)} ${parts[1].substring(5, 8)}";
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_currency.dart';
import '../models/market_prices.dart';
import '../models/product.dart';

class ProductExportService {
  static Future<void> exportProducts(
    List<Product> products,
    MarketPrices marketPrices,
  ) async {
    final data = products.map((product) {
      final latest = product.data.last;

      final priceEuro = product.liveMarketAsset == null
          ? latest.priceEuro
          : marketPrices.liveAssetPrice(
              product.liveMarketAsset!,
              AppCurrency.eur,
            );

      final sats =
          ((priceEuro / marketPrices.btcEur) * 100000000).round();

      return {
        'id': product.id,
        'emoji': product.emoji,
        'name': product.name,
        'priceBTC': _formatSats(sats),
      };
    }).toList();

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/product_data.json',
    );

    await file.writeAsString(jsonEncode(data));
  }

  static String _formatSats(int sats) {
    final value = (sats / 100000000).toStringAsFixed(8);
    final parts = value.split('.');

    return '${parts[0]}.'
        '${parts[1].substring(0, 2)} '
        '${parts[1].substring(2, 5)} '
        '${parts[1].substring(5, 8)}';
  }
}

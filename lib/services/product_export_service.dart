import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_currency.dart';
import '../models/market_prices.dart';
import '../models/product.dart';
import 'widget_sync_service.dart';

class ProductExportService {
  static Future<void> exportProducts(
    List<Product> products,
    MarketPrices marketPrices, {
    required AppCurrency selectedCurrency,
    required bool showSats,
  }) async {
    final payload = <String, dynamic>{
      'schemaVersion': 1,
      'currency': selectedCurrency.code,
      'showSats': showSats,
      'updatedAt': marketPrices.fetchedAt.millisecondsSinceEpoch,
      'market': <String, dynamic>{
        'btcEur': marketPrices.btcEur,
        'btcUsd': marketPrices.btcUsd,
        'ethEur': marketPrices.ethEur,
        'ethUsd': marketPrices.ethUsd,
      },
      'products':
          products.map((product) {
            final latest = product.data.last;

            return <String, dynamic>{
              'id': product.id,
              'name': product.name,
              'emoji': product.emoji,
              'priceEuro': latest.priceEuro,
              'liveAsset': product.liveMarketAsset?.name,
            };
          }).toList(),
    };

    final encoded = jsonEncode(payload);

    // Copie de diagnostic. Le partage réel avec Android passe par
    // MethodChannel afin d'éviter toute ambiguïté de chemin.
    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/widget_product_data.json');
        await file.writeAsString(encoded, flush: true);
      } catch (error) {
        debugPrint('Écriture du diagnostic widget impossible : $error');
      }
    }

    await WidgetSyncService.sync(encoded);
  }
}

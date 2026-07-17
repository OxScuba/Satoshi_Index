import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_translations.dart';
import '../models/app_currency.dart';
import '../models/market_prices.dart';
import '../models/product.dart';
import '../models/user_product.dart';
import 'product_price_resolver.dart';
import 'user_product_price_resolver.dart';
import 'widget_sync_service.dart';

class ProductExportService {
  static Future<void> exportProducts(
    List<Product> products,
    MarketPrices marketPrices, {
    required AppCurrency selectedCurrency,
    required bool showSats,
    required Map<String, double> customPrices,
    required List<UserProduct> userProducts,
  }) async {
    final officialProducts = products.map((product) {
      final effectivePriceEuro = ProductPriceResolver.effectivePriceEuro(
        product: product,
        customPrices: customPrices,
        marketPrices: marketPrices,
      );

      return <String, dynamic>{
        'id': product.id,
        'name': AppTranslations.productName(product.id, product.name),
        'emoji': product.emoji,
        'priceEuro': effectivePriceEuro,
        'priceAmount': effectivePriceEuro,
        'priceCurrency': AppCurrency.eur.code,
        'isUserProduct': false,
        'liveAsset': product.liveMarketAsset?.name,
      };
    });

    final personalProducts = userProducts.map((product) {
      final priceEuro = UserProductPriceResolver.priceInEuro(
        product: product,
        marketPrices: marketPrices,
      );

      return <String, dynamic>{
        'id': product.id,
        'name': product.name,
        'emoji': product.emoji,
        'priceEuro': priceEuro,
        'priceAmount': product.price,
        'priceCurrency': product.currency.code,
        'isUserProduct': true,
        'liveAsset': null,
      };
    });

    final payload = <String, dynamic>{
      'schemaVersion': 4,
      'language': AppTranslations.languageCode,
      'currency': selectedCurrency.code,
      'showSats': showSats,
      'updatedAt': marketPrices.fetchedAt.millisecondsSinceEpoch,
      'market': <String, dynamic>{
        'bitcoin': marketPrices.bitcoinPricesByCode,
        'ethereum': marketPrices.ethereumPricesByCode,
      },
      'products': <Map<String, dynamic>>[
        ...officialProducts,
        ...personalProducts,
      ],
    };

    final encoded = jsonEncode(payload);

    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/widget_product_data.json');
        await file.writeAsString(encoded, flush: true);
      } catch (error) {
        debugPrint(
          'Écriture du diagnostic widget impossible : '
          '$error',
        );
      }
    }

    await WidgetSyncService.sync(encoded);
  }
}

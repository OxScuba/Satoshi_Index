import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/models/app_currency.dart';
import 'package:satoshi_index/models/market_prices.dart';
import 'package:satoshi_index/models/product.dart';
import 'package:satoshi_index/services/product_price_resolver.dart';

void main() {
  final marketPrices = MarketPrices(
    bitcoinPrices: {
      AppCurrency.eur: 60000,
      AppCurrency.usd: 70000,
      AppCurrency.hkd: 546000,
    },
    ethereumPrices: {
      AppCurrency.eur: 1800,
      AppCurrency.usd: 2100,
      AppCurrency.hkd: 16380,
    },
    fetchedAt: DateTime(2026, 7, 15),
  );

  test('utilise le prix personnalisé pour un produit autorisé', () {
    final result = ProductPriceResolver.effectivePriceEuro(
      product: coffeeProduct,
      customPrices: const {'café': 2.20},
      marketPrices: marketPrices,
    );

    expect(result, 2.20);
  });

  test('utilise la référence quand aucun prix personnalisé existe', () {
    final result = ProductPriceResolver.effectivePriceEuro(
      product: coffeeProduct,
      customPrices: const {},
      marketPrices: marketPrices,
    );

    expect(result, coffeeProduct.data.last.priceEuro);
  });

  test('un actif live ignore tout prix personnalisé', () {
    final result = ProductPriceResolver.effectivePriceEuro(
      product: ethereumProduct,
      customPrices: const {'ethereum': 1.0},
      marketPrices: marketPrices,
    );

    expect(result, marketPrices.ethereumPrice(AppCurrency.eur));
  });
}

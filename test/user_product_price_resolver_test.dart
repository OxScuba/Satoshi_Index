import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/models/app_currency.dart';
import 'package:satoshi_index/models/market_prices.dart';
import 'package:satoshi_index/models/user_product.dart';
import 'package:satoshi_index/services/user_product_price_resolver.dart';

void main() {
  final prices = MarketPrices(
    bitcoinPrices: {
      AppCurrency.eur: 60000,
      AppCurrency.usd: 70000,
      AppCurrency.hkd: 546000,
      AppCurrency.rub: 5500000,
    },
    ethereumPrices: {
      AppCurrency.eur: 1800,
      AppCurrency.usd: 2100,
      AppCurrency.hkd: 16380,
      AppCurrency.rub: 165000,
    },
    fetchedAt: DateTime(2026, 7, 15),
  );

  const noodles = UserProduct(
    id: 'user_product_1',
    name: 'Nouilles',
    emoji: '🍜',
    price: 48,
    currency: AppCurrency.hkd,
  );

  test('conserve des identifiants fixes par emplacement', () {
    expect(UserProduct.slotCount, 5);

    expect(UserProduct.idForSlot(0), 'user_product_1');
    expect(UserProduct.idForSlot(1), 'user_product_2');
    expect(UserProduct.idForSlot(2), 'user_product_3');

    expect(noodles.slotIndex, 0);

    expect(() => UserProduct.idForSlot(3), throwsRangeError);
  });

  test('convertit un produit HKD vers EUR', () {
    final result = UserProductPriceResolver.priceInEuro(
      product: noodles,
      marketPrices: prices,
    );

    expect(result, closeTo(48 * 60000 / 546000, 0.000001));
  });

  test('convertit un produit HKD vers USD', () {
    final result = UserProductPriceResolver.priceInCurrency(
      product: noodles,
      targetCurrency: AppCurrency.usd,
      marketPrices: prices,
    );

    expect(result, closeTo(48 * 70000 / 546000, 0.000001));
  });

  test('calcule les satoshis depuis la devise d’origine', () {
    final result = UserProductPriceResolver.priceInSats(
      product: noodles,
      marketPrices: prices,
    );

    expect(result, closeTo(48 / 546000 * 100000000, 0.001));
  });
}
